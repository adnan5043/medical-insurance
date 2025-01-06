class CreateBranches < ActiveRecord::Migration[7.1]
  def change
    create_table :branches do |t|
      t.string :username
      t.string :login
      t.string :password
      t.string :clinical_id

      t.timestamps
    end
  end
end
