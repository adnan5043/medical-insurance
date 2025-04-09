class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

  def index
  end

def download_report
  username = params[:username]
  report_type = params[:report_type]
  @from_date = params[:transaction_from_date].presence
  @to_date = params[:transaction_to_date].presence

  @transactions = if username.present?
                    branch = Branch.find_by(username: username)
                    if branch
                      clinical_id = branch.clinical_id
                      scope = TransactionData.where("sender_id = ? OR receiver_id = ?", clinical_id, clinical_id)
                      scope = scope.where("denial_code IS NOT NULL") if report_type == "rejection"
                      
                      if @from_date && @to_date
                        scope = scope.where(transaction_date: Date.parse(@from_date).beginning_of_day..Date.parse(@to_date).end_of_day)
                      end
                      scope
                    else
                      TransactionData.none
                    end
                  else
                    TransactionData.none
                  end

  respond_to do |format|
    format.html
    format.xlsx do
      report_name = report_type == "rejection" ? "rejection_report" : "full_report"
      render xlsx: report_name, template: "transactions/report"
    end
  end
end

  def show
    @transaction = Transaction.find(params[:id])
    @xml_doc = Nokogiri::XML(@transaction.xml_content)
    @claims = @xml_doc.xpath('//Claim')
  end

  def fetch_transactions
    username = params[:username]
    return render_notification("Username is required.") if username.blank?

    branch = Branch.find_by(username: username)
    return render_notification("Branch with this username not found.") unless branch

    login, password = branch.login, branch.password
    transaction_params = fetch_transactions_params.except(:password, :authenticity_token, :commit, :username)

    # Check if the transaction already exists with the matching login, from_date, and to_date
    if transaction_exists?(login, transaction_params)
      return render_notification("No new request. Same parameters already exist in the database.")
    end

    # Create and save the new SearchTransaction with the provided parameters
    search_transaction = SearchTransaction.new(transaction_params.merge(login: login))

    if search_transaction.save
      # Pass the search_transaction_id to the job and queue it for background processing
      ProcessTransactionsJob.perform_later({
        login: login,
        password: password,
        transaction_from_date: params[:transaction_from_date],
        transaction_to_date: params[:transaction_to_date],
        direction: 2, 
        transaction_id: 8, 
        transaction_status: 1, 
        min_record_count: -1,
        max_record_count: -1,
        sequence: [
          { direction: 2, transaction_id: 8, transaction_status: 2 }, 
          { direction: 1, transaction_id: 2, transaction_status: 1 }, 
          { direction: 1, transaction_id: 2, transaction_status: 2 }
        ],
        search_transaction_id: search_transaction.id  # Include search_transaction_id in the job
      })

      render_notification("Request parameters saved and transaction files will be processed in the background.")
    else
      render_notification("Failed to save request parameters: #{search_transaction.errors.full_messages.join(', ')}")
    end
  end

  private

  def fetch_transactions_params
    params.permit(
      :username, :login, :password, :transaction_id, :direction,
      :transaction_status, :min_record_count, :max_record_count,
      :transaction_from_date, :transaction_to_date, :authenticity_token, :commit
    )
  end

  def transaction_exists?(login, params)
    SearchTransaction.exists?(
      login: login,
      transaction_from_date: params[:transaction_from_date],
      transaction_to_date: params[:transaction_to_date]
    )
  end

  def render_notification(message, type: :notice)
    flash[type] = message
    respond_to do |format|
      format.html { redirect_to root_path } # Adjust to redirect back or handle however needed
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          :notifications, 
          partial: "layouts/flash_notifications", 
          locals: { message: message, type: type }
        )
      end
    end
  end
end
  