# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :merchant
  belongs_to :disbursement, optional: true

  validates :uid,
    presence: true,
    uniqueness: true

  scope :needs_disbursement, -> { where(disbursed: false) }

  def calculated_commision_fee
    commission_rate = case amount
      when 0...50 then 0.01
      when 50...300 then 0.0095
      else 0.0085
    end

    amount * commission_rate
  end

  def calculated_net_amount
    amount - calculated_commision_fee
  end
end
