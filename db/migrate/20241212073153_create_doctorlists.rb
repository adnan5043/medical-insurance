class CreateDoctorlists < ActiveRecord::Migration[7.1]
  def change
    create_table :doctorlists do |t|
      t.string :activity_clinician

      t.timestamps
    end
  end
end
