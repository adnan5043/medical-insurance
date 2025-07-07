class SearchTransaction < ApplicationRecord
  has_many :transactions, foreign_key: :search_transaction_id

  FETCH_BY_USER = 1
  FETCH_BY_SYSTEM = 2

  def fetch_by_s
    fetch_by == 1 ? 'User' : "System"
  end
end
