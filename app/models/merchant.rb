# frozen_string_literal: true

class Merchant < ApplicationRecord
  VALID_DISBURSEMENT_FREQUENCIES = [
    WEEKLY  = "WEEKLY",
    DAILY  = "DAILY",
  ].freeze

  validates :uid,
    presence: true,
    uniqueness: true

  validates :reference,
    presence: true,
    uniqueness: true

  validates :disbursement_frequency,
    inclusion: {
      in: VALID_DISBURSEMENT_FREQUENCIES,
      message: "Invalid Disbursement Frequency"
    }
end
