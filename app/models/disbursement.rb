# frozen_string_literal: true

class Disbursement < ApplicationRecord
  validates :reference,
    presence: true,
    uniqueness: true
  
  belongs_to :merchant

  has_many :orders

  def first_merchant_month_disbursement?
    merchant.disbursements.where(
      year_month: year_month
    ).one?
  end

  def verify_debit
    register_debit if merchant.debit?
  end

  def register_debit
    merchant.monthly_fee_debits.create!(
      amount: merchant.debit_amount,
      disbursement_id: self.id,
    )
  end
end
