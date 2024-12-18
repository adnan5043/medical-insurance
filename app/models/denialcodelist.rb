class Denialcodelist < ApplicationRecord
  validates :denial_code, presence: true
  validates :description, presence: true
  has_many :transaction_data, 
           foreign_key: 'denial_code', 
           primary_key: 'denial_code', 
           class_name: 'TransactionData'
end
