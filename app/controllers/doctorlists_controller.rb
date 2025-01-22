class DoctorlistsController < ApplicationController
  before_action :set_doctorlist, only: %i[show edit update destroy]

  def index
    @doctorlists = Doctorlist.includes(:userable).page(params[:page])
    @doctorlist = Doctorlist.new
    @user = User.new 
  end

  def show
  end

  def new
    @doctorlist = Doctorlist.new
    @user = User.new 
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.new(user_params)
      @user.user_type = "Doctor" 
      @doctorlist = Doctorlist.new(doctorlist_params)
      @doctorlist.userable = @user 

      if @user.save && @doctorlist.save
        redirect_to doctorlists_path, notice: 'Doctor data was successfully created.'
      else
        redirect_to doctorlists_path, alert: 'There were errors creating the doctor'
      end
    end
  end

  def edit
    @user = @doctorlist.userable 
  end

  def update
    ActiveRecord::Base.transaction do
      @user = @doctorlist.userable
      if @user.update(user_params) && @doctorlist.update(doctorlist_params)
        redirect_to doctorlists_path, notice: 'Doctor data was successfully updated.'
      else
        redirect_to doctorlists_path, alert: "Errors: #{@user.errors.full_messages.join(', ')}"
      end
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to doctorlists_path, alert: 'Transaction failed. Please try again.'
  end

  def destroy
    @doctorlist = Doctorlist.find(params[:id])
    if @doctorlist.userable.present?
      @user = @doctorlist.userable
      @user.destroy
    end
    @doctorlist.destroy

    redirect_to doctorlists_url, notice: 'Doctor data was successfully deleted.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to doctorlists_url, alert: "Failed to delete doctor data: #{e.message}"
  end

  private

  def set_doctorlist
    @doctorlist = Doctorlist.find(params[:id])
  end

  def doctorlist_params
    params.require(:doctorlist).permit(:doctor_name, :activity_clinician, :basic_salary, :percentage)
  end

  def user_params
    if params[:user]
      params.require(:user).permit(
        :first_name, :last_name, :phone, :address, :avatar, 
        :employee_designation, :joining_date, :email, 
        :password, :password_confirmation
      )
    elsif params[:doctorlist] && params[:doctorlist][:userable_attributes]
      params.require(:doctorlist).require(:userable_attributes).permit(
        :first_name, :last_name, :phone, :address, :avatar, 
        :employee_designation, :joining_date, :email, 
        :password, :password_confirmation
      )
    else
      raise ActionController::ParameterMissing, 'user'
    end
  end
end
