class AddAdminIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :admin, null: true, foreign_key: true  # Allowing null temporarily
  end
end
