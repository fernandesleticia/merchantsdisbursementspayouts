class AddDisbursementToOrders < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      add_reference :orders, :disbursement, foreign_key: true
    end
  end
end
