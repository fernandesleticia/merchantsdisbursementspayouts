
class MerchantCsvImporter < BaseCsvImporter
  def process_batch
    batch_with_error = false
    merchants_to_process = []

    @batch.each do |row|
      validates_data(row)
      Merchant.create!(
        uid: row["id"],
        reference: row["reference"],
        email: row["email"],
        live_on: Date.parse(row["live_on"]),
        disbursement_frequency: row["disbursement_frequency"],
        minimum_monthly_fee: row["minimum_monthly_fee"],
      )
    rescue StandardError => e
      batch_with_error = true
      log(e.message, row)
      next
    end

    @batch = []
    write_dot(batch_with_error)
  end

  def result_output_stream_header
    CSV.generate_line(["error", "id", "reference", "email", "live_on", "disbursement_frequency", "minimum_monthly_fee"])
  end

  def valid_row?(row)
    row["id"].present? &&
    row["reference"].present? &&
    row["email"].present? &&
    row["live_on"].present? &&
    row["disbursement_frequency"].present? &&
    row["minimum_monthly_fee"].present?
  end

  def log(error, row)
    result_output_stream.write(
      CSV.generate_line(
        [
          error,
          row["id"],
          row["reference"],
          row["email"],
          row["live_on"],
          row["disbursement_frequency"],
          row["minimum_monthly_fee"],
        ]
      )
    )
  end
end
