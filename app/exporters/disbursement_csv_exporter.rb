# frozen_string_literal: true

class DisbursementCsvExporter
  attr_accessor :result_output_stream

  def run
    result_output_stream = File.open("/tmp/disbursements.csv", "w")
    result_output_stream.write(result_output_stream_header)

    disbursements_summary_query = "SELECT * FROM disbursements_summary"

    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY ( #{disbursements_summary_query} ) TO STDOUT WITH CSV;" do
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
