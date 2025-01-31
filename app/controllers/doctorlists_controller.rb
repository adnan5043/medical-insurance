class DoctorlistsController < ApplicationController
  before_action :set_doctorlist, only: %i[show edit update destroy]

  def index
    authorize :settings, :index?
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
      @doctorlist = Doctorlist.new(doctorlist_params)
      @doctorlist.userable = @user 
      @user.admin_id = params[:admin_id] 
      if @user.save && @doctorlist.save
        redirect_to doctorlists_path, notice: 'User data was successfully created.'
      else
        redirect_to doctorlists_path, alert: "Errors: #{@user.errors.full_messages.join(', ')}"
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
        redirect_to doctorlists_path, notice: 'User data was successfully updated.'
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

    redirect_to doctorlists_url, notice: 'User data was successfully deleted.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to doctorlists_url, alert: "Failed to delete User data: #{e.message}"
  end

  private

  def set_doctorlist
    @doctorlist = Doctorlist.find(params[:id])
  end

  def doctorlist_params
    params.require(:doctorlist).permit(:activity_clinician, :percentage, userable_attributes: [:id, :admin_id, :first_name, :last_name, :country_code, :phone, :address, :avatar, :employee_designation, :joining_date, :email, :basic_salary, :password, :password_confirmation])
  end

  def user_params
    params.require(:user).permit(:admin_id, :first_name, :last_name, :country_code, :phone, :address, :avatar, :employee_designation, :joining_date, :email, :basic_salary, :password, :password_confirmation)
  end
end
