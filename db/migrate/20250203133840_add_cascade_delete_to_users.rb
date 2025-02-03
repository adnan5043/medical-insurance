class AddCascadeDeleteToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :users, :admins
    add_foreign_key :users, :admins, on_delete: :cascade
  end
end
