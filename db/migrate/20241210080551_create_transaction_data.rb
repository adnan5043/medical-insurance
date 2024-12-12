class CreateTransactionData < ActiveRecord::Migration[7.1]
  def change
    create_table "transaction_data", force: :cascade do |t|
      t.string "sender_id"
      t.string "receiver_id"
      t.datetime "transaction_date"
      t.integer "record_count"
      t.string "disposition_flag"
      t.string "claim_id"
      t.string "id_payer"
      t.string "provider_id"
      t.string "payment_reference"
      t.datetime "date_settlement"
      t.text "comments"
      t.string "facility_id"
      t.string "activity_id"
      t.datetime "activity_start"
      t.integer "activity_type"
      t.string "activity_code"
      t.integer "activity_quantity"
      t.decimal "activity_net", precision: 10, scale: 2
      t.decimal "activity_list", precision: 10, scale: 2
      t.string "activity_clinician"
      t.decimal "activity_gross", precision: 10, scale: 2
      t.decimal "activity_patient_share", precision: 10, scale: 2
      t.decimal "activity_payment_amount", precision: 10, scale: 2
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "file_id"
      t.references :transaction, null: false, foreign_key: true # Ensure proper foreign key reference
    end
  end
end
