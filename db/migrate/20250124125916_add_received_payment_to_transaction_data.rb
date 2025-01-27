class AddReceivedPaymentToTransactionData < ActiveRecord::Migration[7.1]
  def change
    add_column :transaction_data, :received_payment, :decimal, precision: 15, scale: 2
  end
end
