class ManageReceptionsController < ApplicationController
  before_action :set_manage_reception, only: %i[show edit update destroy]

  def index
    @manage_receptions = ManageReception.includes(:userable).page(params[:page])
    @user = User.new 
  end

  def show
  end

  def new
    @manage_reception = ManageReception.new
    @user = User.new 
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.new(user_params) 
      @manage_reception = ManageReception.new

      if @user.save
        @manage_reception.userable = @user # Associate the user with ManageReception
        if @manage_reception.save
          redirect_to manage_receptions_path, notice: 'Reception was successfully created.'
        else
       redirect_to manage_receptions_path, alert: 'There were errors creating the Reception Manager.'
        end
      else
      redirect_to manage_receptions_path, alert: "There were errors creating the User: #{@user.errors.full_messages.join(', ')}"
      end
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to manage_receptions_path, alert: 'Transaction failed. Please try again.'
  end

  def edit
    @user = @manage_reception.userable 
  end

  def update
    ActiveRecord::Base.transaction do
      @user = @manage_reception.userable
      if @user.update(user_params) && @manage_reception.update(manage_reception_params)
        redirect_to manage_receptions_path, notice: 'Reception was successfully updated.'
      else
        redirect_to manage_receptions_path, alert: "Errors: #{@user.errors.full_messages.join(', ')}"
      end
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to manage_receptions_path, alert: 'Transaction failed. Please try again.'
  end

  def destroy
    ActiveRecord::Base.transaction do
      @user = @manage_reception.userable
      @manage_reception.destroy
      @user.destroy
      redirect_to manage_receptions_url, notice: 'Reception was successfully deleted.'
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to manage_receptions_url, alert: 'There were errors deleting the Reception Manager.'
  end

  private

  def set_manage_reception
    @manage_reception = ManageReception.find(params[:id])
  end

  def manage_reception_params
    params.require(:manage_reception).permit(
    )
  end

  def user_params
    if params[:manage_reception] && params[:manage_reception][:user]
      # Handle nested user params
      params.require(:manage_reception).require(:user).permit(
        :first_name, :last_name, :phone, :address, :avatar, 
        :employee_designation, :joining_date, :email, 
        :password, :password_confirmation
      )
    else
      # Handle direct user params for edit (when not nested)
      params.require(:user).permit(
        :first_name, :last_name, :phone, :address, :avatar, 
        :employee_designation, :joining_date, :email, 
        :password, :password_confirmation
      )
    end
  end
end
