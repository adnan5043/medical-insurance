class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update destroy check_in check_out]

  def index
    @patients = Patient.page(params[:page]) # for pagination
    @patient = Patient.new
  end

  def show
  end

  def new
    @patient = Patient.new
  end

  def create
    @patient = Patient.new(patient_params)

    if Patient.exists?(phone_no: @patient.phone_no) || Patient.exists?(patient_file_no: @patient.patient_file_no)
      render_notification("A patient with this phone number or patient file number already exists.", type: :alert)
    elsif @patient.save
      respond_to do |format|
        format.html { redirect_to patients_path, notice: 'Patient was successfully created.' }
        format.turbo_stream do
          render turbo_stream: turbo_stream.append('patients', partial: 'patients/patient', locals: { patient: @patient })
        end
      end
    else
      render_notification("Errors: #{@patient.errors.full_messages.join(', ')}", type: :alert)
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to patients_path, notice: 'Patient was successfully updated.'
    else
      redirect_to patients_path, alert: "Errors: #{@patient.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @patient.destroy
    redirect_to patients_path, notice: 'Patient was successfully deleted.'
  end

  def check_in
    @patient.update(check_in: Time.current)
    redirect_to patients_path, notice: "Patient checked in successfully."
  end

  def check_out
    if @patient.check_in.blank?
      render_notification("Cannot check out. The patient hasn't checked in yet.", type: :alert)
    else
      if @patient.update(check_out: Time.current)
        redirect_to patients_path, notice: "Patient checked out successfully."
      else
        redirect_to patients_path, alert: "Error: #{@patient.errors.full_messages.join(', ')}"
      end
    end
  end

  private

  def render_notification(message, type: :notice)
    flash[type] = message
    respond_to do |format|
      format.html { redirect_to patients_path }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          :notifications, 
          partial: "layouts/flash_notifications", 
          locals: { message: message, type: type }
        )
      end
    end
  end

  def set_patient
    @patient = Patient.find(params[:id])
  end

  def patient_params
    params.require(:patient).permit(:name, :address, :note, :insurance_type, :patient_file_no, :emirate_id_no, :phone_no, :insurance_no, :status)
  end
end
