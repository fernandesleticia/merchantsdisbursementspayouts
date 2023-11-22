# frozen_string_literal: true

class DisbursementCsvExporter
  attr_accessor :result_output_stream

  def run
    result_output_stream = File.open("/tmp/disbursements.csv", "w")
    result_output_stream.write(result_output_stream_header)

    query = "
      SELECT
        EXTRACT(YEAR FROM disbursement.created_at)::TEXT AS year,
        COUNT(disbursement.id) AS number_of_disbursements,
        TO_CHAR(SUM(disbursement.amount), 'FM999G999G999G999G999D00 €') AS amount_disbursed_to_merchants,
        TO_CHAR(SUM(disbursement.commision_fee), 'FM999G999G999G999G999D00 €') AS amount_of_order_fees,
        COUNT(monthly_fee_debit.id) AS number_of_monthly_fees_charged,
        COALESCE(TO_CHAR(SUM(monthly_fee_debit.amount), 'FM999G999G999G999G999D00 €'), '0.00 €') AS amount_of_monthly_fee_charged
      FROM
        disbursements disbursement
      LEFT JOIN
        monthly_fee_debits monthly_fee_debit ON monthly_fee_debit.disbursement_id = disbursement.id
      GROUP BY
        year
      ORDER BY
        year
    "

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY ( #{query} ) TO STDOUT WITH CSV;" do
      while row = conn.get_copy_data
        result_output_stream.write(row.force_encoding('UTF-8'))
      end
    end
  ensure
    result_output_stream.close
  end

  def result_output_stream_header
    CSV.generate_line([
      "Year",
      "Number of disbursements",
      "Amount disbursed to merchants",
      "Amount of order fees",
      "Number of monthly fees charged (From minimum monthly fee)",
      "Amount of monthly fee charged (From minimum monthly fee)"
    ])
  end
end
