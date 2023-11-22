require 'rails_helper'

RSpec.describe DisbursementJob do

  describe "#perform" do
    subject { DisbursementJob.new }

    let(:today) { Date.today }
    let(:weekday) { Date::DAYNAMES[today.wday].downcase.to_sym }
    let(:same_weekday) { today.weeks_ago(1).beginning_of_week(weekday) }

    let!(:daily_merchant) { create(:merchant, :daily) }
    let!(:weekly_merchant) { create(:merchant, :weekly, live_on: same_weekday) }
    let!(:weekly_merchant_different_weekday) { create(:merchant, :weekly, live_on: 2.days.ago) }

    it "should call disbursement service with the right values" do
      expect(DisbursementService).to receive(:new).
        with(daily_merchant).
        and_return(double("Disbursement Service Instance 1", run: true))

      expect(DisbursementService).to receive(:new).
        with(weekly_merchant).
        and_return(double("Disbursement Service Instance 2", run: true))

      expect(DisbursementService).not_to receive(:new).
        with(weekly_merchant_different_weekday)

      subject.perform
    end
  end
end
