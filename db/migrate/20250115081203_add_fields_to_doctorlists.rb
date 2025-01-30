class AddFieldsToDoctorlists < ActiveRecord::Migration[7.1]
  def change
    # Adding the required fields
    add_column :doctorlists, :percentage, :decimal, precision: 5, scale: 2

    # Adding the polymorphic reference to doctorlists
    add_reference :doctorlists, :userable, polymorphic: true, index: true
  end
end
