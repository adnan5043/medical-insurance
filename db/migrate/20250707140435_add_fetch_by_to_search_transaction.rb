class AddFetchByToSearchTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :search_transactions, :fetch_by, :decimal, default: 1
  end
end
