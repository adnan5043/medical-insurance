class Branch < ApplicationRecord

  validates :username, presence: true, uniqueness: true
  validates :login, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }
  validates :clinical_id, presence: true,uniqueness: true
end
