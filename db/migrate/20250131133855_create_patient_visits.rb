class CreatePatientVisits < ActiveRecord::Migration[7.1]
  def change
    create_table :patient_visits do |t|
      t.references :patient, null: false, foreign_key: true
      t.datetime :check_in
      t.datetime :check_out

      t.timestamps
    end
  end
end
