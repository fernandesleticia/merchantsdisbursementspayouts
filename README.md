# Merchants Disbursements Payouts

## Overview

Automate the calculation of merchants’ disbursements payouts and commissions for existing, present in the CSV files, and new orders.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
- [Development](#development)
- [Testing](#testing)
- [Built With](#built-with)
- [License](#license)

## Getting Started

### Prerequisites

Make sure you have the following software installed before setting up the project:

- Docker
- Docker Compose

### Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/fernandesleticia/merchantsdisbursementspayouts.git
    ```

2. Change into the project directory:

    ```bash
    cd merchantsdisbursementspayouts
    ```

3. Build and run the Docker containers:

    ```bash
    docker compose build
    ```

    ```bash
    docker compose up
    ```

4. Create the database and run migrations:

    ```bash
    docker-compose run web rake db:create db:migrate
    ```

5. Visit `http://localhost:3000` in your browser to see the application.

## Usage

## Development

## Testing

## Built With

- [Ruby on Rails](https://rubyonrails.org/)
- [Docker](https://www.docker.com/)

## License

This project is licensed under the [MIT License](LICENSE).
