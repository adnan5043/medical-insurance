class PatientVisit < ApplicationRecord
  belongs_to :patient
  validates :check_in, presence: true
  validate :check_out_after_check_in

  private

  def check_out_after_check_in
    return if check_out.blank? || check_in.blank?

    if check_out < check_in
      errors.add(:check_out, "must be after the check-in time")
    end
  end
end
