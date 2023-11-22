# frozen_string_literal: true

class DisbursementService
  extend Memoist

  attr_reader :merchant, :disbursement

  def initialize(merchant)
    @merchant = merchant
    @disbursement = merchant.create_disbursement!
  end

  def run
    ActiveRecord::Base.transaction do
      disbursement.verify_debit

      update_disbursement
      update_orders
    end
  end

  def update_disbursement
    disbursement.amount = total_orders_net_amount.round(2)
    disbursement.commision_fee = total_orders_commission_fee.round(2)

    disbursement.save!
  end

  def update_orders
    orders.update_all(disbursement_id: disbursement.id, disbursed: true)
  end

  def total_orders_net_amount
    orders.map(&:calculated_net_amount).sum
  end

  def total_orders_commission_fee
    orders.map(&:calculated_commision_fee).sum
  end

  def orders
    merchant.orders.needs_disbursement
  end
  memoize :orders
end
