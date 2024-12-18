class SearchTransaction < ApplicationRecord
  validates :transaction_id, :direction, :transaction_status, presence: true
end
