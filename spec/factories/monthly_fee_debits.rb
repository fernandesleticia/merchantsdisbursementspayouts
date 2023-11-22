FactoryBot.define do
  factory :monthly_fee_debit do
    merchant
    amount { 10.0 }
  end
end
