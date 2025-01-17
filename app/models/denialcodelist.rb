class Denialcodelist < ApplicationRecord
  require 'roo'

  validates :denial_code, presence: true
  validates :description, presence: true
  has_many :transaction_data, 
           foreign_key: 'denial_code', 
           primary_key: 'denial_code', 
           class_name: 'TransactionData'
  validates :effective_from, presence: true
  validate :effective_dates_order

  private

  def effective_dates_order
    if effective_to.present? && effective_from > effective_to
      errors.add(:effective_to, "must be after the effective_from date")
    end
  end
end
