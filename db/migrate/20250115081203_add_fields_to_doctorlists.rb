class AddFieldsToDoctorlists < ActiveRecord::Migration[7.1]
  def change
    add_column :doctorlists, :license_number, :string
    add_column :doctorlists, :first_name, :string
    add_column :doctorlists, :last_name, :string
    add_column :doctorlists, :email, :string
    add_column :doctorlists, :phone, :string
    add_column :doctorlists, :address, :string
    add_column :doctorlists, :avatar, :string
    add_column :doctorlists, :employee_designation, :string
    add_column :doctorlists, :joining_date, :date
    add_column :doctorlists, :basic_salary, :decimal, precision: 10, scale: 2
    add_column :doctorlists, :percentage, :decimal, precision: 5, scale: 2
  end
end
