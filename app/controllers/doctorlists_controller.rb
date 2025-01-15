class DoctorlistsController < ApplicationController
  before_action :set_doctorlist, only: %i[show edit update destroy]

  def index
    @doctorlists = Doctorlist.page(params[:page])
    @doctorlist = Doctorlist.new
  end

  def show
  end

  def new
    @doctorlist = Doctorlist.new
  end

  def create
    @doctorlist = Doctorlist.new(doctorlist_params)
    if @doctorlist.save
      redirect_to doctorlists_path, notice: 'Doctor_data was successfully created.'
    else
      render :new
    end
  end

  def edit
    # @doctorlist is already set by before_action
  end

  def update
    if @doctorlist.update(doctorlist_params)
      redirect_to doctorlists_path, notice: 'Doctor_data was successfully updated.'
    else
      redirect_to doctorlists_path, alert: 'There were errors updating the doctorlist.'
    end
  end

  def destroy
    @doctorlist.destroy
    redirect_to doctorlists_url, notice: 'Doctor_data was successfully destroyed.'
  end

  private

  def set_doctorlist
    @doctorlist = Doctorlist.find(params[:id])
  end

  def doctorlist_params
    params.require(:doctorlist).permit(
      :doctor_name, 
      :activity_clinician, 
      :license_number, 
      :first_name, 
      :last_name, 
      :email, 
      :phone, 
      :address, 
      :avatar, 
      :employee_designation, 
      :joining_date, 
      :basic_salary, 
      :percentage
    )
  end
end
