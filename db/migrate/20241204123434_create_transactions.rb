class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.string :file_id
      t.text :xml_content

      t.timestamps
    end
  end
end
