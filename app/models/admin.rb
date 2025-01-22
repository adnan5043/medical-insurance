class Admin < ApplicationRecord
  has_many :users 
  validates :title, presence: true
  serialize :permissions, JSON
end
