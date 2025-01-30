class AddUserTypeToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :basic_salary, :decimal, precision: 10, scale: 2
    add_column :users, :user_type, :string
  end
end
