# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order do
  before { create(:order) }

  describe "associations" do
    it { is_expected.to belong_to(:merchant) }
  end

  context "validations" do
    it { should validate_presence_of(:uid) }
    it { should validate_uniqueness_of(:uid) }
  end
end
