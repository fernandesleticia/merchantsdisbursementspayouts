class OrderCsvImporter < BaseCsvImporter
  def process_batch
    batch_with_error = false
    orders_to_process = []

    @batch.each do |row|
      validates_data(row)

      merchant = Merchant.find_by_reference!(row["merchant_reference"])

      Order.create!(
        uid: row["id"],
        merchant: merchant,
        amount: row["amount"],
        creation_date: Date.parse(row["created_at"]),
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
    CSV.generate_line(["error", "id", "merchant_reference", "amount", "created_at"])
  end

  def valid_row?(row)
    row["id"].present? &&
    row["merchant_reference"].present? &&
    row["amount"].present? &&
    row["created_at"].present?
  end

  def log(error, row)
    result_output_stream.write(
      CSV.generate_line(
        [
          error,
          row["id"],
          row["merchant_reference"],
          row["amount"],
          row["created_at"]
        ]
      )
    )
  end
end
