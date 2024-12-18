class AddDenialCodeToTransactionData < ActiveRecord::Migration[7.1]
  def change
    add_column :transaction_data, :denial_code, :string
  end
end
