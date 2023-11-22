FactoryBot.define do
  factory :merchant do
    uid { SecureRandom.uuid }
    disbursement_frequency { Merchant::DAILY }
    reference { SecureRandom.alphanumeric(10) }
    email { "info@padberg-group.com" }
    live_on { 2.months.ago }
    minimum_monthly_fee { 100.0 }

    trait :daily do
      disbursement_frequency { Merchant::DAILY }
    end

    trait :weekly do
      disbursement_frequency { Merchant::WEEKLY }
    end
  end
end
