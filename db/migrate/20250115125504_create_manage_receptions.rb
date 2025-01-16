class CreateManageReceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :manage_receptions do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :phone
      t.text :address
      t.string :avatar
      t.string :employee_designation
      t.date :joining_date

      t.timestamps
    end
  end
end
