class AddDataTypeToTransactionData < ActiveRecord::Migration[7.1]
  def change
    add_column :transaction_data, :data_type, :string
  end
end
