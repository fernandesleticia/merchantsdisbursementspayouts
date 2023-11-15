# frozen_string_literal: true

require "rails_helper"

RSpec.describe Merchant do
  before { create(:merchant) }

  context "validations" do
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
end
