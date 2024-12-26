class AddLoginToSearchTransactions < ActiveRecord::Migration[7.1]
  def change
    add_column :search_transactions, :login, :string
  end
end
