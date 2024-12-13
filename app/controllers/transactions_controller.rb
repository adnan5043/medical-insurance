class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

  def index
    @transactions = TransactionData.all
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
    direction = 1
    transaction_id = 2
    transaction_status = 2 
    min_record_count = -1
    max_record_count = -1
    transaction_from_date = '01/01/2024 00:00'
    transaction_to_date = '26/02/2024 23:59'

    # transaction_files_xml = fetch_transaction_files(login, password)
    # Fetch transaction files using HTTP request
    transaction_files_xml = fetch_transaction_files_using_http(
      login, password, direction, transaction_id, transaction_status,
      min_record_count, max_record_count, transaction_from_date, transaction_to_date
    )

    if transaction_files_xml.present?
      Rails.logger.info "Transaction files XML: #{transaction_files_xml}"
      # Optionally, process the XML here
    else
      Rails.logger.warn "No transaction files found"
    end

    # if transaction_files_xml.present?
    #   file_ids = Nokogiri::XML(transaction_files_xml).xpath("//File/@FileID").map(&:value)

    #   if file_ids.any?
    #     Rails.logger.info "Processing FileIDs: #{file_ids.inspect}"

    #     # Download transaction files using the fetched File ID
    #     file_ids.each do |file_id|
    #       fetch_file_details_from_soap(file_id, login, password)
    #     end
    #   else
    #     Rails.logger.warn "No FileIDs found in the fetched transactions"
    #   end
    # else
    #   Rails.logger.warn "No transaction files were retrieved from the SOAP service"
    # end
  end

  private

  def fetch_transaction_files_using_http(login, password, direction, transaction_id, transaction_status, min_record_count, max_record_count, transaction_from_date, transaction_to_date)
      uri = URI.parse("http://dhpo.eclaimlink.ae/ValidateTransactions.asmx")

      # Define the XML body for the raw SOAP HTTP request
      request_body = <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
          <soap:Body>
            <SearchTransactions xmlns="http://www.eClaimLink.ae/">
              <login>#{login}</login>
              <pwd>#{password}</pwd>
              <direction>#{direction}</direction>
              <transactionID>#{transaction_id}</transactionID>
              <TransactionStatus>#{transaction_status}</TransactionStatus>
              <minRecordCount>#{min_record_count}</minRecordCount>
              <maxRecordCount>#{max_record_count}</maxRecordCount>
              <transactionFromDate>#{transaction_from_date}</transactionFromDate>
              <transactionToDate>#{transaction_to_date}</transactionToDate>
            </SearchTransactions>
          </soap:Body>
        </soap:Envelope>
      XML

      # Create the POST request for the SOAP servic
      request = Net::HTTP::Post.new(uri.path,
                                    { 'Content-Type' => 'text/xml; charset=utf-8',
                                      'SOAPAction' => '"http://www.eClaimLink.ae/SearchTransactions"' })
      request.body = request_body

      # Send the request and handle the response
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(request) }
      Rails.logger.info("SOAP Response (HTTP): #{response.body}")
      transaction_files_xml=response.body
    rescue StandardError => e
      Rails.logger.error "HTTP Request Error: #{e.message}"
      nil
  end

  # def fetch_transaction_files(login, password)
  #   # SOAP client setup
  #   client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")
  #   begin
  #     response = client.call(:get_new_transactions, message: { login: login, pwd: password })
  #     transaction_files_xml = response.body.dig(:get_new_transactions_response, :xml_transaction)
      
  #     return transaction_files_xml
  #   rescue Savon::Error => e
  #     Rails.logger.error "SOAP Error: #{e.message}"
  #     nil
  #   end
  # end

  # def fetch_file_details_from_soap(file_id, login, password)
  #   if Transaction.exists?(file_id: file_id)
  #     Rails.logger.info "File ID #{file_id} already exists. Skipping..."
  #     return nil 
  #   end

  #   client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")
  #   begin
  #     # Make SOAP call to fetch the file details
  #     response = client.call(:download_transaction_file, message: { login: login, pwd: password, fileId: file_id })
  #     # puts response.inspect
  #     file_content_base64 = response.body.dig(:download_transaction_file_response, :file)

  #     decoded_data = Base64.decode64(file_content_base64) 
  #     if decoded_data.present?
  #       # Create the Transaction record
  #       transaction = Transaction.create!(file_id: file_id, xml_content: decoded_data)
        
  #       # Save the related TransactionData
  #       transaction.save_transaction_data
  #     else
  #       Rails.logger.warn "No file content found for File ID #{file_id}"
  #     end  
  #   rescue Savon::Error => e
  #     Rails.logger.error "SOAP Error: #{e.message}"
  #     nil
  #   end
  # end
end
