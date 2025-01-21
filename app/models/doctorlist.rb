class Doctorlist < ApplicationRecord
  validates :activity_clinician, presence: true, uniqueness: true
  validates :doctor_name, presence: true

  belongs_to :userable, polymorphic: true
  accepts_nested_attributes_for :userable
  
  has_many :transaction_data, 
           foreign_key: 'activity_clinician', 
           primary_key: 'activity_clinician', 
           class_name: 'TransactionData'
end
