class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

  def index
  end

  def download_report
    username = params[:username]
    @transactions = if username.present?
                      branch = Branch.find_by(username: username)
                      if branch
                        clinical_id = branch.clinical_id
                        TransactionData.where("sender_id = ? OR receiver_id = ?", clinical_id, clinical_id)
                      else
                        TransactionData.none
                      end
                    else
                      TransactionData.none
                    end

    respond_to do |format|
      format.html
      format.xlsx { render xlsx: "report", template: "transactions/report" }
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

    login, password = branch.login,branch.password 

    transaction_params = fetch_transactions_params.except(:password, :authenticity_token, :commit, :username)
    if transaction_exists?(login, transaction_params)
      return render_notification("No new request. Same parameters already exist in the database.")
    end

    search_transaction = SearchTransaction.new(transaction_params.merge(login: login))
    if search_transaction.save
      ProcessTransactionsJob.perform_later(fetch_transactions_params.merge(
                                             login: login,
                                             password: password,
                                             search_transaction_id: search_transaction.id
                                           ))
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
      transaction_id: params[:transaction_id],
      direction: params[:direction],
      transaction_status: params[:transaction_status],
      min_record_count: params[:min_record_count],
      max_record_count: params[:max_record_count],
      transaction_from_date: params[:transaction_from_date].presence,
      transaction_to_date: params[:transaction_to_date].presence
    )
  end

  def render_notification(message)
    render turbo_stream: turbo_stream.append(:notifications, message)
  end
end
