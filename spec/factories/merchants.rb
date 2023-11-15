FactoryBot.define do
  factory :merchant do
    uid { SecureRandom.uuid }
    reference { SecureRandom.alphanumeric(10) }
    email { "info@padberg-group.com" }
    live_on { 2.months.ago }
    disbursement_frequency { "DAILY" }
    minimum_monthly_fee { 100.0 }
  end
end
