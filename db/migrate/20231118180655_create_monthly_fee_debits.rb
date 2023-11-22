class CreateMonthlyFeeDebits < ActiveRecord::Migration[6.1]
  def change
    create_table :monthly_fee_debits do |t|
      t.references :merchant, foreign_key: true, index: true
      t.references :disbursement, foreign_key: true, index: true
      t.float :amount

      t.timestamps
    end
  end
end
