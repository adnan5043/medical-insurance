class DenialcodelistsController < ApplicationController
  before_action :set_denialcodelist, only: [ :edit, :update, :destroy]

  def index
    @denialcodelists = Denialcodelist.all
  end

  def new
    @denialcodelist = Denialcodelist.new
  end

  def create
    @denialcodelist = Denialcodelist.new(denialcodelist_params)
    if @denialcodelist.save
      redirect_to denialcodelists_path, notice: 'Denial code was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @denialcodelist.update(denialcodelist_params)
      redirect_to denialcodelists_path, notice: 'Denial code was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @denialcodelist.destroy
    redirect_to denialcodelists_path, notice: 'Denial code was successfully destroyed.'
  end

  private

  def set_denialcodelist
    @denialcodelist = Denialcodelist.find(params[:id])
  end

  def denialcodelist_params
    params.require(:denialcodelist).permit(:denial_code, :description)
  end
end
