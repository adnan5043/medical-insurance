class ManageReceptionsController < ApplicationController
  before_action :set_manage_reception, only: %i[show edit update destroy]
  def index
    @manage_receptions = ManageReception.page(params[:page]) 
    @manage_reception = ManageReception.new
  end

  def show
  end

  def new
    @manage_reception = ManageReception.new
  end

  def create
    @manage_reception = ManageReception.new(manage_reception_params)
    if @manage_reception.save
      redirect_to manage_receptions_path, notice: 'Reception was successfully created.'
    else
      render :new, alert: 'There were errors creating the Reception Manager.'
    end
  end

  def edit
  end

  def update
    if @manage_reception.update(manage_reception_params)
      redirect_to manage_receptions_path, notice: 'Reception  was successfully updated.'
    else
      redirect_to manage_receptions_path, alert: "errors: #{@branch.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @manage_reception.destroy
    redirect_to manage_receptions_url, notice: 'Reception was successfully deleted.'
  end

  private

  def set_manage_reception
    @manage_reception = ManageReception.find(params[:id])
  end

  def manage_reception_params
    params.require(:manage_reception).permit(
      :first_name, 
      :last_name, 
      :username, 
      :phone, 
      :address, 
      :avatar, 
      :employee_designation, 
      :joining_date
    )
  end
end
