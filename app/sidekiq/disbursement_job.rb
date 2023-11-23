# frozen_string_literal: true

require 'sidekiq-scheduler'

class DisbursementJob
  include Sidekiq::Worker

  def perform
    disburse_orders
  end

  def disburse_orders
    Merchant.ready_for_disbursement.each do |merchant|
      DisbursementService.new(merchant).run
    end
  end
end
