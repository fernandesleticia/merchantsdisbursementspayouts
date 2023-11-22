# frozen_string_literal: true

require "rails_helper"

RSpec.describe Merchant do
  context "validations" do
    before { create(:merchant) }

    it { should validate_presence_of(:uid) }
    it { should validate_uniqueness_of(:uid) }
    it { should validate_presence_of(:reference) }
    it { should validate_uniqueness_of(:reference) }

    it do
      is_expected.to validate_inclusion_of(:disbursement_frequency)
        .in_array(Merchant::VALID_DISBURSEMENT_FREQUENCIES)
        .with_message(/Invalid Disbursement Frequency/)
    end
  end

  describe "scopes" do
    describe ".ready_for_disbursement" do
      subject { Merchant.ready_for_disbursement }

      let(:today) { Date.today }
      let(:weekday) { Date::DAYNAMES[today.wday].downcase.to_sym }
      let(:same_weekday) { Date.today.weeks_ago(1).beginning_of_week(weekday) }

      let!(:daily_merchant) { create(:merchant, :daily) }
      let!(:weekly_merchant_live_on_same_weekday) { create(:merchant, :weekly, live_on: same_weekday) }
      let!(:weekly_merchant_live_on_different_weekday) { create(:merchant, :weekly, live_on: 2.days.ago) }

      it "should return only the merchants that are ready to be disbursed" do
        expect(subject).to match_array([daily_merchant, weekly_merchant_live_on_same_weekday])
      end
    end
  end
end
