class AddIndexToMerchantReference < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :merchants, :reference, unique: true, algorithm: :concurrently
  end
end
