class CreatePatients < ActiveRecord::Migration[7.1]
  def change
    create_table :patients do |t|
      t.string :name
      t.text :address
      t.text :note
      t.string :insurance_type
      t.string :patient_file_no
      t.string :emirate_id_no
      t.string :phone_no
      t.string :insurance_no
      t.string :status

      t.timestamps
    end
  end
end
