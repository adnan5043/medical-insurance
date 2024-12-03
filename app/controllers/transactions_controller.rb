class TransactionsController < ApplicationController
  def download
    if request.post?
      login = params[:login]
      password = params[:password]
      file_id = params[:file_id]

      # Validate inputs
      if login.blank? || password.blank? || file_id.blank?
        flash[:error] = "Please provide all the fields: Username, Password, and File ID."
        return render :download
      end

      # Call the SOAP API to download the transaction file
      response = download_transaction_file(login, password, file_id)

      # Check if the response is successful and contains the downloaded file
      if response && response[:downloaded_file]
        send_data response[:downloaded_file], filename: 'transaction_file.xml', type: 'application/xml'
      else
        flash[:error] = "Incorrect Username, Password, or File ID. Please check your details."
        render :download
      end
    end
  end

  private

  def download_transaction_file(login, password, file_id)
    client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")

    # Create the SOAP request
    begin
      response = client.call(:download_transaction_file, message: {
        login: login,
        pwd: password,
        fileId: file_id
      })

      # Check if the response is successful and extract the file data
      if response.success?
        downloaded_file = response.body.dig(:downloadtransactionfile_response, :downloaded_file)
        if downloaded_file
          # Decode the file if it exists (assuming it's base64-encoded)
          { downloaded_file: Base64.decode64(downloaded_file) }
        else
          nil
        end
      else
        nil
      end
    rescue Savon::Error => e
      Rails.logger.error "SOAP request failed: #{e.message}"
      nil
    end
  end
end
