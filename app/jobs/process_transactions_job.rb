class ProcessTransactionsJob < ApplicationJob
  queue_as :default

  def perform(params)
    login = params[:login]
    password = params[:password]
    direction = params[:direction].to_i
    transaction_id = params[:transaction_id].to_i
    transaction_status = params[:transaction_status].to_i
    min_record_count = params[:min_record_count].to_i
    max_record_count = params[:max_record_count].to_i
    transaction_from_date = params[:transaction_from_date]
    transaction_to_date = params[:transaction_to_date]

    # Adjust min and max record counts as per requirements
    min_record_count = -1 if min_record_count.zero?
    max_record_count = -1 if max_record_count.zero? || max_record_count < min_record_count

    # Fetch transaction files using HTTP request
    transaction_files_xml = fetch_transaction_files_using_http(
      login, password, direction, transaction_id, transaction_status,
      min_record_count, max_record_count, transaction_from_date, transaction_to_date
    )

    if transaction_files_xml.present?
      file_ids = transaction_files_xml.scan(/FileID= '([a-f0-9\-]+)'/).flatten
      if file_ids.any?
        Rails.logger.info "Processing FileIDs: #{file_ids.inspect}"
        file_ids.each do |file_id|
          fetch_file_details_from_soap(file_id, login, password)
        end
      else
        Rails.logger.warn "No FileIDs found in the fetched transactions"
      end
    else
      Rails.logger.warn "No transaction files were retrieved from the SOAP service"
    end

    # Process the next job in the sequence, if available
    if params[:sequence]&.any?
      next_job_params = params[:sequence].shift
      ProcessTransactionsJob.perform_later(params.merge(next_job_params))
    end
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

    # Create the POST request for the SOAP service
    request = Net::HTTP::Post.new(uri.path,
                                  { 'Content-Type' => 'text/xml; charset=utf-8',
                                    'SOAPAction' => '"http://www.eClaimLink.ae/SearchTransactions"' })
    request.body = request_body

    # Send the request and handle the response
    response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(request) }
    Rails.logger.info("SOAP Response (HTTP): #{response.body}")
    response.body
  rescue StandardError => e
    Rails.logger.error "HTTP Request Error: #{e.message}"
    nil
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
      file_content_base64 = response.body.dig(:download_transaction_file_response, :file)

      decoded_data = Base64.decode64(file_content_base64) 
      if decoded_data.present?
        # Create the Transaction record
        transaction = Transaction.create!(file_id: file_id, xml_content: decoded_data)
        
        # Save the related TransactionData
        transaction.save_transaction_data
      else
        Rails.logger.warn "No file content found for File ID #{file_id}"
      end  
    rescue Savon::Error => e
      Rails.logger.error "SOAP Error: #{e.message}"
      nil
    end
  end
end
