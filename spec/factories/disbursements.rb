FactoryBot.define do
  factory :disbursement do
    merchant
    reference { SecureRandom.alphanumeric(10) }
    year_month { "2023_02" }
    amount { 0.0  }
    commision_fee { 0.0 }
  end
end
