class Doctorlist < ApplicationRecord
  belongs_to :userable, polymorphic: true
  accepts_nested_attributes_for :userable
  
  has_many :transaction_data, 
           foreign_key: 'activity_clinician', 
           primary_key: 'activity_clinician', 
           class_name: 'TransactionData'
end
