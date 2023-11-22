# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order do
  describe "associations" do
    it { is_expected.to belong_to(:merchant) }
  end

  context "validations" do
    before { create(:order) }

    it { should validate_presence_of(:uid) }
    it { should validate_uniqueness_of(:uid) }
  end

  describe "scopes" do
    describe ".needs_disbursement" do
      let!(:orders_not_disbursed) { create_list(:order, 5, disbursed: false) }

      before do
        create_list(:order, 5, disbursed: true)
      end

      it "should return only the orders that needs disbursement" do
        expect(Order.needs_disbursement).to match_array(orders_not_disbursed)
      end
    end
  end
end
