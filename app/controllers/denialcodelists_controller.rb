class DenialcodelistsController < ApplicationController
  before_action :set_denialcodelist, only: [:edit, :update, :destroy]

  def index
    authorize :settings, :index?
    @denialcodelists = Denialcodelist.page(params[:page])
    @denialcodelist = Denialcodelist.new
  end

  def import
    upload_file
  end

  def new
    @denialcodelist = Denialcodelist.new
  end

  def create
    @denialcodelist = Denialcodelist.new(denialcodelist_params)
    if @denialcodelist.save
      redirect_to denialcodelists_path, notice: 'Denial code was successfully created.'
    else
      redirect_to denialcodelists_path, alert: "errors: #{@denialcodelist.errors.full_messages.join(', ')}"
    end
  end

  def edit; end

  def update
    if @denialcodelist.update(denialcodelist_params)
      redirect_to denialcodelists_path, notice: 'Denial code was successfully updated.'
    else
      redirect_to denialcodelists_path, alert: "errors: #{@denialcodelist.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @denialcodelist.destroy
    redirect_to denialcodelists_path, notice: 'Denial code was successfully destroyed.'
  end

  private

  def upload_file
    if params[:file].present?
      file = params[:file]
      spreadsheet = Roo::Spreadsheet.open(file)

      header = spreadsheet.row(1)
      skipped_records = [] 
      imported_records = 0 

      (2..spreadsheet.last_row).each do |i| 
        row = Hash[[header, spreadsheet.row(i)].transpose]

        effective_from = row['Effective From'].is_a?(Date) ? row['Effective From'] : Date.parse(row['Effective From'].to_s)
        effective_to = row['Effective To'].present? ? Date.parse(row['Effective To'].to_s) : nil

        # Skip the record if the denial code already exists
        denial_code = row['Code']
        if Denialcodelist.exists?(denial_code: denial_code)
          skipped_records << denial_code
          next
        end

        Denialcodelist.create!(
          denial_code: denial_code,
          description: row['Description'],
          effective_from: effective_from,
          effective_to: effective_to
        )
        imported_records += 1
      end

      # Display a notice with the result of the import
      message = "File imported successfully. #{imported_records} records added."
      message += " Skipped #{skipped_records.count} duplicate records" if skipped_records.any?
      redirect_to denialcodelists_path, notice: message
    else
      redirect_to denialcodelists_path, alert: 'No file uploaded'
    end
  rescue StandardError => e
    redirect_to denialcodelists_path, alert: "Error importing file: #{e.message}"
  end

  def set_denialcodelist
    @denialcodelist = Denialcodelist.find(params[:id])
  end

  def denialcodelist_params
    params.require(:denialcodelist).permit(:denial_code, :description, :effective_from, :effective_to)
  end
end
