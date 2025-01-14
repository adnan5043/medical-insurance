class BranchesController < ApplicationController
  before_action :set_branch, only: %i[show edit update destroy]

  def index
  @branches = Branch.page(params[:page])
  # @branches = Branch.all
  @branch = Branch.new
  end

  def show
  end

  def new
    @branch = Branch.new
  end

  def create
    @branch = Branch.new(branch_params)

    # Check if a branch with the same username, login, or clinical_id exists
    if Branch.exists?(username: @branch.username) || Branch.exists?(login: @branch.login) || Branch.exists?(clinical_id: @branch.clinical_id)
      return render_notification("A branch with this username, login, or clinical ID already exists.")
    elsif @branch.save
      redirect_to branches_path, notice: 'Branch was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
      @branch = Branch.find(params[:id])
  end

  def update
    if @branch.update(branch_params)
      redirect_to branches_path, notice: 'Branch was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @branch.destroy
    redirect_to branches_path, notice: 'Branch was successfully deleted.'
  end

  private

  def render_notification(message, type: :notice)
    flash[type] = message
    respond_to do |format|
      format.html { redirect_to branches_path } 
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          :notifications, 
          partial: "layouts/flash_notifications", 
          locals: { message: message, type: type }
        )
      end
    end
  end

  def set_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:username, :login, :password, :clinical_id)
  end
end
