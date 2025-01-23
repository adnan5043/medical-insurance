class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar
  has_many :manage_reception, as: :userable, dependent: :destroy
  has_many :doctorlists, as: :userable, dependent: :destroy

  belongs_to :admin, optional: true

  def allowed_permissions
    return ["Report", "Admin", "Settings","API Request","Patient"] if email == "medicalinsurance@gmail.com"
    admin_permissions = admin&.permissions || []
    matched_admin = Admin.find_by(title: user_type)
    matched_permissions = matched_admin&.permissions || []

    admin_permissions + matched_permissions
  end
end
