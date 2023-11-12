class CreateMerchants < ActiveRecord::Migration[6.1]
  def change
    create_table :merchants do |t|
      t.string :uid, null: false
      t.string :reference, null: false
      t.string :disbursement_frequency
      t.string :email
      t.date :live_on
      t.float :minimum_monthly_fee

      t.timestamps
    end
  end
end
