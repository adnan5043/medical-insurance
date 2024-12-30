class AddSearchTransactionIdToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :search_transaction_id, :integer
    add_index :transactions, :search_transaction_id
    add_foreign_key :transactions, :search_transactions
  end
end
