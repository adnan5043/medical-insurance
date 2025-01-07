class SearchTransaction < ApplicationRecord
  has_many :transactions, foreign_key: :search_transaction_id
end
