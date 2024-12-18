class CreateSearchTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :search_transactions do |t|
      t.integer :transaction_id
      t.integer :direction
      t.integer :transaction_status
      t.integer :min_record_count
      t.integer :max_record_count
      t.datetime :transaction_from_date
      t.datetime :transaction_to_date

      t.timestamps
    end
  end
end
