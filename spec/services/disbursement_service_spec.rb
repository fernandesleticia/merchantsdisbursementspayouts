require 'rails_helper'

RSpec.describe DisbursementService do
  describe "#run" do
    subject { DisbursementService.new(merchant).run }

    let(:today) { Date.today }
    let(:weekday) { Date::DAYNAMES[today.wday].downcase.to_sym }
    let(:same_weekday) { today.weeks_ago(1).beginning_of_week(weekday) }

    let(:minimum_monthly_fee) { 30.00 }
    let(:merchant) { create(:merchant, :daily, minimum_monthly_fee: minimum_monthly_fee) }

    let!(:order1) { create(:order, disbursed: false, amount: 10.25, merchant: merchant) }
    let!(:order2) { create(:order, disbursed: false, amount: 89.56, merchant: merchant) }
    let!(:order3) { create(:order, disbursed: false, amount: 378.46, merchant: merchant) }
    let!(:order4) { create(:order, disbursed: false, amount: 49.99, merchant: merchant) }
    let!(:order5) { create(:order, disbursed: false, amount: 50.00, merchant: merchant) }
    let!(:order6) { create(:order, disbursed: false, amount: 50.01, merchant: merchant) }
    let!(:order7) { create(:order, disbursed: false, amount: 299.99, merchant: merchant) }
    let!(:order8) { create(:order, disbursed: false, amount: 300.00, merchant: merchant) }
    let!(:order9) { create(:order, disbursed: false, amount: 300.01, merchant: merchant) }

    let(:orders_to_disburse) { [order1.reload, order2.reload, order3.reload, order4.reload, order5.reload, order6.reload, order7.reload, order8.reload, order9.reload] }
    let(:this_year_month) { today.strftime('%Y_%m') }
    let(:previous_year_month) { today.last_month.strftime('%Y_%m') }
    let(:disbursement) { merchant.disbursements.where(year_month: this_year_month).last }

    before do
      create_list(:order, 5, disbursed: true, amount: 10.00, merchant: merchant)
    end

    it "should disburse orders with the right amount and commission fee" do
      subject

      expect(orders_to_disburse.pluck(:disbursed).uniq.first).to be_truthy
      expect(orders_to_disburse.pluck(:disbursement_id).uniq.first).to eq(disbursement.id)

      expect(Disbursement.count).to eq(1)
      expect(disbursement).to have_attributes(
        merchant_id: merchant.id,
        reference: "#{merchant.reference}_#{today.strftime("%Y%m%d")}",
        amount: 1514.7,
        commision_fee: 13.57, 
        year_month: this_year_month,
      )

      expect(MonthlyFeeDebit.count).to eq(1)
      expect(MonthlyFeeDebit.last).to have_attributes(
        merchant_id: merchant.id,
        disbursement_id: disbursement.id,
        amount: minimum_monthly_fee,
      )
    end

    it "should calculate monthly fee debit correctly if there is debit" do
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 5.00)
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 15.00)
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 9.99)

      subject

      expect(MonthlyFeeDebit.count).to eq(1)
      expect(MonthlyFeeDebit.last).to have_attributes(
        merchant_id: merchant.id,
        disbursement_id: disbursement.id,
        amount: 0.010000000000001563,
      )
    end

    it "should not register monthly fee debit if there is no debit" do
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 5.01)
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 15.00)
      create(:disbursement, merchant: merchant, year_month: previous_year_month, commision_fee: 9.99)

      subject

      expect(MonthlyFeeDebit.count).to be_zero
    end
  end
end
