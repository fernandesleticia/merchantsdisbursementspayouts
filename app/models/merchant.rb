# frozen_string_literal: true

class Merchant < ApplicationRecord
  VALID_DISBURSEMENT_FREQUENCIES = [
    WEEKLY = "WEEKLY",
    DAILY = "DAILY",
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
  
  has_many :orders
  has_many :disbursements
  has_many :monthly_fee_debits

  scope :ready_for_disbursement, -> {
    where(disbursement_frequency: DAILY)
    .or(
      where(
        "disbursement_frequency = :frequency AND EXTRACT(DOW FROM live_on) = :weekday",
        frequency: WEEKLY,
        weekday: Date.today.wday,
      )
    )
  }

  def debit?
    debit_amount > 0 
  end

  def debit_amount
    debit = (minimum_monthly_fee - paid_fee(previous_year_month)).round(2)

    [debit, 0].max
  end

  def paid_fee(year_month)
    disbursements.
      where(year_month: year_month).
      sum(:commision_fee)
  end

  def create_disbursement!
    disbursements.create!(
      reference: disbursement_reference,
      year_month: Date.today.strftime('%Y_%m'),
      amount: 0.0,
      commision_fee: 0.0,
    )
  end

  def previous_year_month
    Date.today.last_month.strftime('%Y_%m')
  end

  def disbursement_reference
    "#{reference}_#{Date.today.strftime("%Y%m%d")}"
  end
end
