class AdminsController < ApplicationController
  def index
    @admins = Admin.all
    @admin = Admin.new
  end

  def new
    @admin = Admin.new
  end

  def create
    @admin = Admin.new(admin_params)
    if @admin.save
      redirect_to admins_path, notice: "Permissions successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @admin = Admin.find(params[:id])
    if @admin.update(admin_params)
      redirect_to admins_path, notice: "Permissions successfully updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy
    redirect_to admins_path, notice: "Permissions successfully deleted!"
  end

  private

  def admin_params
    params.require(:admin).permit(:title, permissions: [])
  end
end
