class TransactionData < ApplicationRecord
  belongs_to :transaction_record, class_name: 'Transaction', foreign_key: 'transaction_id'
  belongs_to :doctorlist, 
             foreign_key: 'activity_clinician', 
             primary_key: 'activity_clinician', 
             optional: true
  belongs_to :denialcodelist, 
              foreign_key: 'denial_code', 
              primary_key: 'denial_code',  
             optional: true
             

end
