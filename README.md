# Merchants Disbursements Payouts

## Overview

Automate the calculation of merchants’ disbursements payouts and commissions for existing, present in the CSV files, and new orders.

## Table of Contents

- [Architecture Decisions](#architecture-decisions)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
- [Run](#run)
- [Testing](#testing)
- [Disbursement Summary](#disbursement-summary)
- [Built With](#built-with)
- [License](#license)

## Architecture Decisions
### Data Ingestion and Storage:

#### Importing Orders and Merchants
 The import phase parse the provided Orders CSV and Merchants CSV files for orders and merchants.
 The data parsed is stored in a PostgreSQL database for easier retrieval and manipulation in the disbursement proccess.

  * Bulk insert and update

    I opted for using ActiveRecord-Import in the Disbursement process for handling the creation of orders and merchants to increase the performance by allowing the insertion of multiple orders and merchants in a single database query. For orders importing, the choice was particularly advantageous as is this case the import deals with a large dataset.

    The orders import still can take some time to complete if the csv file is particularly large, it would be nice to improve this phase to report back on progress. ActiveRecord-Import provides an alternative for that by passing a callable as the batch_progress option.
    ```
      my_proc = ->(rows_size, num_batches, current_batch_number, batch_duration_in_secs) {
        # Using the arguments provided to the callable, you can
        # send an email, post to a websocket,
        # update slack, alert if import is taking too long, etc.
      }

      Order.import columns, orders, batch_progress: my_proc
    ```

  * Balancing Speed and Validation Precision

    ActiveRecord-Import prioritizes speed over the execution of ActiveRecord validations and callbacks. While this makes the insertion process faster, it implies that records may be inserted without undergoing the complete set of validations and callbacks defined in the ActiveRecord models. This can potentially lead to data inconsistencies if not managed carefully. Rigorous validation checks remain integral to maintaining data integrity throughout the import process.

### Disbursement Engine

  The job schedules the disbursement calculation process to run daily at 00:00 UTC to identify merchants eligible for daily or weekly disbursements based on their configured frequencies.

  The DisbursementJob triggers the DisbursementService to calculate disbursements for merchants based on the orders data. 

 #### Job scheduling
  
 * Sidekiq

    I opted for Sidekiq to handle background jobs due to its robust multithreaded architecture, significantly enhancing the speed of job processing. This feature is particularly advantageous for the disbursement job, which may involve processing a substantial volume of orders based on the merchant's size and processing frequency. 
 
    For larger merchants processed on a weekly basis, the ability to parallelize the processing of orders is essential. Sidekiq excels in managing heavy job loads and high concurrency without a proportional increase in resource consumption, making it an optimal choice for our requirements.

 * Sidekiq Scheduler

    In selecting Sidekiq Scheduler over OS-based cron jobs, the primary consideration was the need for prompt job execution. OS-based cron jobs incur delays during bootup, resulting in a lag of seconds to minutes in executing the disbursement job. Contrastingly, Sidekiq Scheduler seamlessly operates as part of the Sidekiq process, eliminating bootup delays and ensuring timely execution.

    The decision is further reinforced by the superior error monitoring capabilities offered by Sidekiq Scheduler. Leveraging the standard Sidekiq UI and application error monitoring tools enhances our ability to track and manage potential issues effectively.

    However, it's essential to acknowledge that Sidekiq Scheduler relies on Redis for job scheduling. Should the Redis instance experience downtime or become unavailable, scheduled jobs may face disruptions. Additionally, the centralized nature of Sidekiq Scheduler introduces the possibility of it becoming a single point of failure. To address this concern, implementing redundancy measures and robust monitoring becomes imperative to mitigate potential risks.

 #### Operations
  * Rounding up after sum the amount and commission fee

    I'm rounding up the amount and commission fees after the sum instead of during calculation to mitigate potential errors. 
    
    This approach ensures that each calculation utilizes the precise values, preventing cumulative discrepancies that may arise from rounding at each step. By maintaining the accuracy of the original values throughout the computation, I reduce the likelihood of calculation errors accumulating over time.

  * Mapping and sum amount and fees

    I'm consolidating the amounts and commission fees by mapping and summing them before assigning these aggregated values to the disbursement instead of processing the orders one by one. 
    
    This helps streamline the process, preventing the need for multiple queries to update individual disbursements and orders.

### Disbursement Data Export
#### Disbursement Data Export

 * Database Query

    The core of the export process lies in the SQL query. The decision to use SQL to fetch aggregated data directly from the database is to ensure optimal performance.

 * Complexity

    While a detailed query provides valuable insights, it may become challenging to maintain and modify over time. Careful consideration is required to strike a balance between query complexity and long-term maintainability.

    Considering the potential for query complexity, introducing database views enhances maintainability. By encapsulating the logic within a view, the SQL query becomes more modular and easier to modify. Views also can provide an abstraction layer, allowing the application to interact with the data as if it were a table. This approach enhances code organization and readability.

    The query is executed every time we refer to the disbursement view, materialized views could provide a performance boost by serving some kind of cached data. Fortunately, scenic gem also provides support for materialized views and that can be added if needed.

 * Writing to CSV

    The decision to use the COPY TO STDOUT WITH CSV PostgreSQL command is a performant choice for exporting data directly into a CSV file. The direct streaming of data from the database to the CSV file minimizes memory usage, making it suitable for large datasets.

## Getting Started

### Prerequisites

Make sure you have the following software installed before setting up the project:

- Docker
- Docker Compose

### Setup

1. Place `merchants.csv` and `orders.csv` files in the `/tmp` folder on your local machine

2. Clone the repository:

    ```bash
    git clone https://github.com/fernandesleticia/merchantsdisbursementspayouts.git
    ```

3. Change into the project directory:

    ```bash
    cd merchantsdisbursementspayouts
    ```

4. Build the Docker container:

    ```bash
    docker-compose build
    ```

    ```bash
    docker-compose up
    ```

5. Create the database and run migrations:

    ```bash
    docker compose run app rake db:create db:migrate
    docker compose run app rake db:migrate
    ```
## Run

 1. Import Merchants
    ```bash
    docker-compose run app bin/rake merchants:import[tmp/merchants.csv]
    ```
 2. Import Orders

    **note**: Import orders can take some time to complete

    ```bash
    docker-compose run app bin/rake orders:import[tmp/orders.csv]
    ```
 3. Start sidekiq is started the job is scheduleld to run every day at midnight UTC

    start sidekiq
    ```bash
     docker-compose run app sidekiq
    ```

    run the job manually
    ```bash
      docker-compose run app rails c

      DisbursementJob.new.perform
    ```
 4. After the disbursement job runned, the disbursements processed can be exported:
    ```bash
    docker-compose run app bin/rake disbursements:export
    ```

 5. Get the disbursement report generated
    ```bash
     docker cp <container-id>:/merchantsdisbursementspayouts/tmp/disbursements.csv /tmp/disbursements.csv
    ```

## Testing

Run tests

  ```bash
    docker compose run app bundle exec rspec
  ```

## Disbursement Summary
Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged (From minimum monthly fee) | Amount of monthly fee charged (From minimum monthly fee)
--- | --- | --- | --- |--- |---
2023 | 39 | 141,128,149.01 € | 1,283,011.38 € | 26 | 630.00 €



## Built With

- [Ruby on Rails](https://rubyonrails.org/)
- [Docker](https://www.docker.com/)

## License

This project is licensed under the [MIT License](LICENSE).
