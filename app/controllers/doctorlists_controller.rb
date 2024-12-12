class DoctorlistsController < ApplicationController
  before_action :set_doctorlist, only: %i[show edit update destroy]

  def index
    @doctorlists = Doctorlist.all
  end

  def show
  end

  def new
    @doctorlist = Doctorlist.new
  end

  def create
    @doctorlist = Doctorlist.new(doctorlist_params)
    if @doctorlist.save
      redirect_to doctorlists_path, notice: 'Doctorlist was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @doctorlist.update(doctorlist_params)
      redirect_to @doctorlist, notice: 'Doctorlist was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @doctorlist.destroy
    redirect_to doctorlists_url, notice: 'Doctorlist was successfully destroyed.'
  end

  private

  def set_doctorlist
    @doctorlist = Doctorlist.find(params[:id])
  end

  def doctorlist_params
    params.require(:doctorlist).permit(:doctor_name, :activity_clinician)
  end
end
