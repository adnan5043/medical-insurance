class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

  def index
  end

  def download_report
    username = params[:username]
    user_id = params[:user_id]

    if username.present? && user_id.present?
      @transactions = TransactionData.where("sender_id = ? OR receiver_id = ?", user_id, user_id)
    else
      @transactions = TransactionData.none
    end

    respond_to do |format|
      format.html
      format.xlsx do
        render xlsx: "report", template: "transactions/report"
      end
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
    @xml_doc = Nokogiri::XML(@transaction.xml_content)
    @claims = @xml_doc.xpath('//Claim')
  end

  def fetch_transactions
    # Exclude password from params before saving it to the database
    transaction_params = fetch_transactions_params.to_h.except(:password,:authenticity_token,:commit )

    # Check if a record with the same values already exists
    existing_transaction = SearchTransaction.find_by(
      login: transaction_params[:login],
      transaction_id: transaction_params[:transaction_id],
      direction: transaction_params[:direction],
      transaction_status: transaction_params[:transaction_status],
      min_record_count: transaction_params[:min_record_count],
      max_record_count: transaction_params[:max_record_count],
      transaction_from_date: transaction_params[:transaction_from_date].presence,
      transaction_to_date: transaction_params[:transaction_to_date].presence
    )

    if existing_transaction
      render turbo_stream: turbo_stream.append(:notifications, "No new request. Same parameters already exist in the database.")
      return
    end

    # Save the new record without the password
    search_transaction = SearchTransaction.new(transaction_params)

    if search_transaction.save
      ProcessTransactionsJob.perform_later(fetch_transactions_params.merge(search_transaction_id: search_transaction.id))
      render turbo_stream: turbo_stream.append(:notifications, "Request parameters saved and transaction files will be processed in the background.")
    else
      render turbo_stream: turbo_stream.append(:notifications, "Failed to save request parameters: #{search_transaction.errors.full_messages.join(', ')}")
    end
  end

  private

  def fetch_transactions_params
    params.permit(
      :login, 
      :password, 
      :transaction_id, 
      :direction, 
      :transaction_status, 
      :min_record_count, 
      :max_record_count, 
      :transaction_from_date, 
      :transaction_to_date,
      :authenticity_token, 
      :commit
    )
  end
end
