class AddMissingFieldsToTransactionData < ActiveRecord::Migration[7.1]
  def change
    add_column :transaction_data, :member_id, :string
    add_column :transaction_data, :emirates_id_number, :string
    add_column :transaction_data, :encounter_patient_id, :string
    add_column :transaction_data, :encounter_start_type, :integer
    add_column :transaction_data, :diagnosis_type, :string
    add_column :transaction_data, :diagnosis_code, :string
    add_column :transaction_data, :observation_type, :string
    add_column :transaction_data, :observation_code, :string
    add_column :transaction_data, :observation_value, :string
    add_column :transaction_data, :observation_value_type, :string

    # New Fields
    add_column :transaction_data, :claim_payer_id, :string
    add_column :transaction_data, :claim_net, :string
    add_column :transaction_data, :claim_gross, :decimal, precision: 10, scale: 2
    add_column :transaction_data, :claim_patient_share, :decimal, precision: 10, scale: 2
    add_column :transaction_data, :encounter_type, :integer
    add_column :transaction_data, :encounter_start, :datetime
    add_column :transaction_data, :encounter_end, :datetime
  end
end
