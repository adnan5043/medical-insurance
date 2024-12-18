class CreateDenialcodelist < ActiveRecord::Migration[7.1]
  def change
    create_table :denialcodelists do |t|
      t.string :denial_code
      t.text :description

      t.timestamps
    end
  end
end
