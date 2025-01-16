class ManageReception < ApplicationRecord
  validates :first_name, :last_name, :username, :phone, :employee_designation, :joining_date, presence: true
  # validates :username, format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email" }, uniqueness: true
  # validates :phone, format: { with: /\A\d{10}\z/, message: "must be a valid 10-digit number" }
  has_one_attached :avatar
end
