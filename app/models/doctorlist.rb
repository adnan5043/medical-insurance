class Doctorlist < ApplicationRecord
  validates :activity_clinician, presence: true, uniqueness: true
  validates :doctor_name, presence: true


  has_many :transaction_data, 
           foreign_key: 'activity_clinician', 
           primary_key: 'activity_clinician', 
           class_name: 'TransactionData'
end
