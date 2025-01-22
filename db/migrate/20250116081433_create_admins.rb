class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string :title
      t.text :permissions

      t.timestamps
    end
  end
end
