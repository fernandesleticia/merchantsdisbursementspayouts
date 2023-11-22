class CreateDisbursements < ActiveRecord::Migration[6.1]
  def change
    create_table :disbursements do |t|
      t.references :merchant, foreign_key: true, index: true      
      t.string :reference, null: false
      t.float :amount
      t.float :commision_fee
      t.string :year_month

      t.timestamps
    end
  end
end
