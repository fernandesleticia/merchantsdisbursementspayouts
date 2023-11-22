# frozen_string_literal: true

class OrderCsvImporter < BaseCsvImporter
  BATCH_SIZE = 100

  def process_batch
    begin
      Order.import columns, orders, validate: true
    rescue StandardError => e
      batch_with_error = true
      log(e.message, @batch)
    end

    @batch = []
  end

  def columns
    %i[uid merchant_id amount creation_date]
  end

  def orders
    batch_with_error = false
    orders = []

    @batch.each do |row|
      validates_data(row)

      merchant = Merchant.find_by_reference!(row["merchant_reference"])
      orders << [row["id"], merchant.id, row["amount"], Date.parse(row["created_at"])]
    rescue StandardError => e
      batch_with_error = true
      log(e.message, @batch, row: row)
      next
    end

    write_dot(batch_with_error)
    orders
  end

  def valid_row?(row)
    row["id"].present? &&
    row["merchant_reference"].present? &&
    row["amount"].present? &&
    row["created_at"].present?
  end
end
