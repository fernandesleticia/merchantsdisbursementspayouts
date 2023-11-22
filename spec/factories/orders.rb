FactoryBot.define do
  factory :order do
    uid { SecureRandom.uuid }
    merchant
    amount { 100.0 }
    creation_date { 2.months.ago }

    trait :disbursed do
      disbursed { true }
    end
  end
end
