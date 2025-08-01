class AddCommonFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :address, :text
    add_column :users, :avatar, :string
    add_column :users, :employee_designation, :string
    add_column :users, :joining_date, :date
  end
end
