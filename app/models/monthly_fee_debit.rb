# frozen_string_literal: true

class MonthlyFeeDebit < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement
end
