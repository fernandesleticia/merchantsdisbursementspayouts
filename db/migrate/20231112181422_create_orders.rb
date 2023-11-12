class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :merchant, foreign_key: true, index: true
      t.string :uid, null: false
      t.boolean :disbursed, default: false
      t.float :amount
      t.date :creation_date

      t.timestamps
    end
  end
end
