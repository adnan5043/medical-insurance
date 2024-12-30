class SearchTransaction < ApplicationRecord
  validates :transaction_id, :direction, :transaction_status, presence: true
  has_many :transactions, foreign_key: :search_transaction_id

end
