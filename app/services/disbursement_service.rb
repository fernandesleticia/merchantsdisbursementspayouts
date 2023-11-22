# frozen_string_literal: true

class DisbursementService
  attr_reader :merchant, :disbursement

  def initialize(merchant)
    @merchant = merchant
    @disbursement = merchant.create_disbursement!
  end

  def run
    disbursement.verify_debit if disbursement.first_merchant_month_disbursement?

    merchant.orders.needs_disbursement.each do |order|
      disburse(order)
    end
  end

  def disburse(order)
    ActiveRecord::Base.transaction do
      process_disbursement(order)
      process_order(order)
    end
  end

  def process_disbursement(order)
    disbursement.amount += order.calculated_net_amount
    disbursement.commision_fee += order.calculated_commision_fee
    disbursement.save!
  end

  def process_order(order)
    order.disbursement = disbursement
    order.disbursed = true
    order.save!
  end
end
