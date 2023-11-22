# frozen_string_literal: true

require "rails_helper"

RSpec.describe DisbursementCsvExporter do
  Timecop.freeze do
    describe "#run" do
      subject { DisbursementCsvExporter.new.run }

      let(:disbursements_file) { "/tmp/disbursements.csv" }

      before do
        merchant = create(:merchant)
        merchant2 = create(:merchant)

        disbursement = create(:disbursement, created_at: 3.years.ago, amount: 1000.00, commision_fee: 10.00, merchant: merchant2)
        create(:disbursement, created_at: 3.years.ago, amount: 1000.00, commision_fee: 10.00, merchant: merchant2)
        create(:monthly_fee_debit, created_at: 3.years.ago, amount: 50.0, merchant: merchant2, disbursement: disbursement)

        disbursement2 = create(:disbursement, created_at: 1.year.ago, amount: 1000.00, commision_fee: 10.00, merchant: merchant)
        create(:disbursement, created_at: 1.year.ago, amount: 1000.00, commision_fee: 10.00, merchant: merchant)
        create(:disbursement, created_at: 1.year.ago, amount: 500.00, commision_fee: 1.00, merchant: merchant)
        create(:monthly_fee_debit, created_at: 1.year.ago, amount: 50.0, merchant: merchant, disbursement: disbursement2)

        create(:disbursement, created_at: Date.today, amount: 200.00, commision_fee: 20.00, merchant: merchant)
        create(:disbursement, created_at: Date.today, amount: 200.00, commision_fee: 20.00, merchant: merchant2)
      end

      after(:each) do
        File.delete(disbursements_file) if File.exist?(disbursements_file)
      end

      it "should export disbursements correctly" do
        subject

        disbursements_csv = CSV.open(disbursements_file, "r")

        expect(disbursements_csv.first).to eq([
          "Year",
          "Number of disbursements",
          "Amount disbursed to merchants",
          "Amount of order fees",
          "Number of monthly fees charged (From minimum monthly fee)",
          "Amount of monthly fee charged (From minimum monthly fee)"
        ])

        expect(disbursements_csv.first).to eq(["2020", "2", "2,000.00 €", "20.00 €", "1", "50.00 €"])
        expect(disbursements_csv.first).to eq(["2022", "3", "2,500.00 €", "21.00 €", "1", "50.00 €"])
        expect(disbursements_csv.first).to eq(["2023", "2", "400.00 €", "40.00 €", "0", "0.00 €"])
      end
    end
  end
end
