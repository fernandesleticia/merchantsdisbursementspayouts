
# frozen_string_literal: true

class MerchantCsvImporter < BaseCsvImporter
  def process_batch
    begin
      Merchant.import columns, merchants, validate: true
    rescue StandardError => e
      batch_with_error = true
      log(e.message, @batch)
    end

    @batch = []
  end

  def columns
    %i[uid reference email live_on disbursement_frequency minimum_monthly_fee]
  end

  def merchants
    batch_with_error = false
    merchants = []

    @batch.each do |row|
      validates_data(row)

      merchants << [row["id"], row["reference"], row["email"], Date.parse(row["live_on"]), row["disbursement_frequency"], row["minimum_monthly_fee"]]
    rescue StandardError => e
      batch_with_error = true
      log(e.message, @batch, row: row)
      next
    end

    write_dot(batch_with_error)
    merchants
  end

  def valid_row?(row)
    row["id"].present? &&
    row["reference"].present? &&
    row["email"].present? &&
    row["live_on"].present? &&
    row["disbursement_frequency"].present? &&
    row["minimum_monthly_fee"].present?
  end
end
