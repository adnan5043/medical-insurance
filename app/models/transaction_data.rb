class TransactionData < ApplicationRecord
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :doctorlist, 
             foreign_key: 'activity_clinician', 
             primary_key: 'activity_clinician', 
             optional: true
end
