class Patient < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :phone_no, presence: true, uniqueness: true
  validates :status, inclusion: { in: ['active', 'inactive'] }
  validate :check_out_after_check_in
  
  private

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?

    if check_out < check_in
      errors.add(:check_out, "must be after the check-in time")
    end
  end
end
