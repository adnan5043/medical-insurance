class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

  def index
    @transactions = Transaction.all
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
    login = ENV['SOAP_USERNAME']
    password = ENV['SOAP_PASSWORD']
    transaction_files_xml = fetch_transaction_files(login, password)

    if transaction_files_xml.present?
      file_ids = Nokogiri::XML(transaction_files_xml).xpath("//File/@FileID").map(&:value)

      if file_ids.any?
        Rails.logger.info "Processing FileIDs: #{file_ids.inspect}"

        # Download transaction files using the fetched File ID
        file_ids.each do |file_id|
          fetch_file_details_from_soap(file_id, login, password)
        end
      else
        Rails.logger.warn "No FileIDs found in the fetched transactions"
      end
    else
      Rails.logger.warn "No transaction files were retrieved from the SOAP service"
    end
  end

  private

  def fetch_transaction_files(login, password)
    # SOAP client setup
    client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")
    begin
      response = client.call(:get_new_transactions, message: { login: login, pwd: password })
      transaction_files_xml = response.body.dig(:get_new_transactions_response, :xml_transaction)
      
      return transaction_files_xml
    rescue Savon::Error => e
      Rails.logger.error "SOAP Error: #{e.message}"
      nil
    end
  end

  def fetch_file_details_from_soap(file_id, login, password)
    if Transaction.exists?(file_id: file_id)
      Rails.logger.info "File ID #{file_id} already exists. Skipping..."
      return nil 
    end

    client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")
    begin
      # Make SOAP call to fetch the file details
      response = client.call(:download_transaction_file, message: { login: login, pwd: password, fileId: file_id })
      # puts response.inspect
      file_content_base64 = response.body.dig(:download_transaction_file_response, :file)

      decoded_data = Base64.decode64(file_content_base64) 
      if decoded_data.present?
      # Rails.logger.info "Decoded Data for File ID #{file_id}: #{decoded_data}"
      Transaction.create!(file_id: file_id, xml_content: decoded_data)
      else
      Rails.logger.warn "No file content found for File ID #{file_id}"
      end  
    rescue Savon::Error => e
      Rails.logger.error "SOAP Error: #{e.message}"
      nil
    end
  end
end
