class Patient < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :phone_no, presence: true, uniqueness: true
  validates :status, inclusion: { in: ['active', 'inactive'] }
  has_many :patient_visits, dependent: :destroy

end
