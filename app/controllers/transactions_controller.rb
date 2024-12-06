class TransactionsController < ApplicationController
  require 'nokogiri'
  require 'base64'

def index
  # Assuming response_body is retrieved earlier
  if response_body.present?
    decoded_xml = Base64.decode64(response_body)
    @xml_doc = Nokogiri::XML(decoded_xml)
          Rails.logger.info "Parsed XML: #{@xml_doc}"

  else
    # Handle the case when response_body is nil or empty
    flash[:error] = "Invalid or missing response body"
    # redirect_to some_other_path # Or handle the error as needed
  end
end



  def fetch_transactions
    login = ENV['SOAP_USERNAME']
    password = ENV['SOAP_PASSWORD']

    # Fetch new transactions first
    fetch_transaction_files(login, password)

    # After fetching the transactions, you can manually download the transaction files using the file IDs
    manual_file_ids = [
      'b7c818ee-a111-447a-9dde-e477142e4854',
      'ee073927-864c-4dbf-8cf2-4663516b1ff5',
      'b75a3f62-cf0b-45a9-b77a-8a25b00c80d8',
      '861b3029-18ef-4648-ace2-dc1d276018eb'
    ]

    # Log the manually defined file IDs for debugging
    if manual_file_ids.present?
      Rails.logger.info "Manually Defined FileIDs: #{manual_file_ids.join(', ')}"
    else
      Rails.logger.warn "No FileIDs found"
    end

    # Download transaction files using the predefined file IDs
    manual_file_ids.each do |file_id|
      fetch_file_details_from_soap(file_id, login, password)
    end
  end

  private

  def fetch_transaction_files(login, password)
    # SOAP client setup
    client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")

    begin
      Rails.logger.info "Available SOAP operations: #{client.operations.inspect}"
      response = client.call(:get_new_transactions, message: { login: login, pwd: password })
      Rails.logger.info "SOAP Response: #{response.body.inspect}"
      transaction_files = response.body[:get_new_transactions_response][:get_new_transactions_result]

      # Log the transaction files retrieved from the response
      if transaction_files.present?
        Rails.logger.info "Transaction Files Retrieved: #{transaction_files.inspect}"
      else
        Rails.logger.warn "No transaction files found in response"
      end
      return transaction_files
    rescue Savon::Error => e
      Rails.logger.error "SOAP Error: #{e.message}"
      nil
    end
  end

  def fetch_file_details_from_soap(file_id, login, password)
    client = Savon.client(wsdl: "http://dhpo.eclaimlink.ae/ValidateTransactions.asmx?WSDL")

    begin
      response = client.call(:download_transaction_file, message: { login: login, pwd: password, fileID: file_id })
      # Rails.logger.info "File Details Response for File IDddd #{file_id}: #{response.body.inspect}"
      Rails.logger.info "File Details Response for File IDddd #{file_id}: #{response_body}"
      response.body
      response_body = " PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjxSZW1pdHRhbmNlLkFkdmljZSB4bWxuczp0bnM9Imh0dHA6Ly93d3cuZWNsYWltbGluay5hZS9ESEQvVmFsaWRhdGlvblNjaGVtYSIgeG1sbnM6eHNpPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxL1hNTFNjaGVtYS1pbnN0YW5jZSIgeHNpOm5vTmFtZXNwYWNlU2NoZW1hTG9jYXRpb249Imh0dHA6Ly93d3cuZWNsYWltbGluay5hZS9ESEQvVmFsaWRhdGlvblNjaGVtYS9SZW1pdHRhbmNlQWR2aWNlLnhzZCI+DQogIDxIZWFkZXI+DQogICAgPFNlbmRlcklEPlRQQTAwMTwvU2VuZGVySUQ+DQogICAgPFJlY2VpdmVySUQ+REhBLUYtMDA0NzA4MTwvUmVjZWl2ZXJJRD4NCiAgICA8VHJhbnNhY3Rpb25EYXRlPjMxLzEyLzIwMjIgMDA6MzA8L1RyYW5zYWN0aW9uRGF0ZT4NCiAgICA8UmVjb3JkQ291bnQ+NTwvUmVjb3JkQ291bnQ+DQogICAgPERpc3Bvc2l0aW9uRmxhZz5QUk9EVUNUSU9OPC9EaXNwb3NpdGlvbkZsYWc+DQogIDwvSGVhZGVyPg0KICA8Q2xhaW0+DQogICAgPElEPkQxMDQzMDQgLSBESEEtRi0wMDQ3MDgxLkouU3ViLlNFUC0yMi5ORVUtUlRBIC0gMTwvSUQ+DQogICAgPElEUGF5ZXI+NjM5MjMzNy0zNjwvSURQYXllcj4NCiAgICA8UHJvdmlkZXJJRD5ESEEtRi0wMDQ3MDgxPC9Qcm92aWRlcklEPg0KICAgIDxQYXltZW50UmVmZXJlbmNlPkJUMjIxMjI4MDc2OTQ5NjQ8L1BheW1lbnRSZWZlcmVuY2U+DQogICAgPERhdGVTZXR0bGVtZW50PjI5LzEyLzIwMjIgMDA6MDA8L0RhdGVTZXR0bGVtZW50Pg0KICAgIDxDb21tZW50cz4NCiAgICA8L0NvbW1lbnRzPg0KICAgIDxFbmNvdW50ZXI+DQogICAgICA8RmFjaWxpdHlJRD5ESEEtRi0wMDQ3MDgxPC9GYWNpbGl0eUlEPg0KICAgIDwvRW5jb3VudGVyPg0KICAgIDxBY3Rpdml0eT4NCiAgICAgIDxJRD41NzAzNzc1NDwvSUQ+DQogICAgICA8U3RhcnQ+MjIvMDkvMjAyMiAyMTozOTwvU3RhcnQ+DQogICAgICA8VHlwZT42PC9UeXBlPg0KICAgICAgPENvZGU+RDAyMjA8L0NvZGU+DQogICAgICA8UXVhbnRpdHk+MTwvUXVhbnRpdHk+DQogICAgICA8TmV0PjQzLjIwPC9OZXQ+DQogICAgICA8TGlzdD40My4yMDwvTGlzdD4NCiAgICAgIDxDbGluaWNpYW4+REhBLVAtMDA0MDk3MDwvQ2xpbmljaWFuPg0KICAgICAgPEdyb3NzPjU0PC9Hcm9zcz4NCiAgICAgIDxQYXRpZW50U2hhcmU+MTAuODA8L1BhdGllbnRTaGFyZT4NCiAgICAgIDxQYXltZW50QW1vdW50PjQzLjIwPC9QYXltZW50QW1vdW50Pg0KICAgIDwvQWN0aXZpdHk+DQogIDwvQ2xhaW0+DQogIDxDbGFpbT4NCiAgICA8SUQ+UDEwMDIwOSAtIERIQS1GLTAwNDcwODEuSi5TdWIuU0VQLTIyLk5FVS1SVEEgLSAyPC9JRD4NCiAgICA8SURQYXllcj42MzkyMzM3LTM3PC9JRFBheWVyPg0KICAgIDxQcm92aWRlcklEPkRIQS1GLTAwNDcwODE8L1Byb3ZpZGVySUQ+DQogICAgPFBheW1lbnRSZWZlcmVuY2U+QlQyMjEyMjgwNzY5NDk2NDwvUGF5bWVudFJlZmVyZW5jZT4NCiAgICA8RGF0ZVNldHRsZW1lbnQ+MjkvMTIvMjAyMiAwMDowMDwvRGF0ZVNldHRsZW1lbnQ+DQogICAgPENvbW1lbnRzPg0KICAgIDwvQ29tbWVudHM+DQogICAgPEVuY291bnRlcj4NCiAgICAgIDxGYWNpbGl0eUlEPkRIQS1GLTAwNDcwODE8L0ZhY2lsaXR5SUQ+DQogICAgPC9FbmNvdW50ZXI+DQogICAgPEFjdGl2aXR5Pg0KICAgICAgPElEPjU3MDM3NzU1PC9JRD4NCiAgICAgIDxTdGFydD4wMS8wOS8yMDIyIDE2OjI2PC9TdGFydD4NCiAgICAgIDxUeXBlPjY8L1R5cGU+DQogICAgICA8Q29kZT5ENzIxMDwvQ29kZT4NCiAgICAgIDxRdWFudGl0eT4xPC9RdWFudGl0eT4NCiAgICAgIDxOZXQ+OTcyPC9OZXQ+DQogICAgICA8TGlzdD45NzI8L0xpc3Q+DQogICAgICA8Q2xpbmljaWFuPkRIQS1QLTE1MTk2MzY2PC9DbGluaWNpYW4+DQogICAgICA8R3Jvc3M+MTA4MDwvR3Jvc3M+DQogICAgICA8UGF0aWVudFNoYXJlPjEwODwvUGF0aWVudFNoYXJlPg0KICAgICAgPFBheW1lbnRBbW91bnQ+OTcyPC9QYXltZW50QW1vdW50Pg0KICAgIDwvQWN0aXZpdHk+DQogIDwvQ2xhaW0+DQogIDxDbGFpbT4NCiAgICA8SUQ+SjEwMzQzOCAtIERIQS1GLTAwNDcwODEuSi5TdWIuU0VQLTIyLk5FVS1SVEEgLSAzPC9JRD4NCiAgICA8SURQYXllcj42MzkyMzM3LTM4PC9JRFBheWVyPg0KICAgIDxQcm92aWRlcklEPkRIQS1GLTAwNDcwODE8L1Byb3ZpZGVySUQ+DQogICAgPFBheW1lbnRSZWZlcmVuY2U+QlQyMjEyMjgwNzY5NDk2NDwvUGF5bWVudFJlZmVyZW5jZT4NCiAgICA8RGF0ZVNldHRsZW1lbnQ+MjkvMTIvMjAyMiAwMDowMDwvRGF0ZVNldHRsZW1lbnQ+DQogICAgPENvbW1lbnRzPg0KICAgIDwvQ29tbWVudHM+DQogICAgPEVuY291bnRlcj4NCiAgICAgIDxGYWNpbGl0eUlEPkRIQS1GLTAwNDcwODE8L0ZhY2lsaXR5SUQ+DQogICAgPC9FbmNvdW50ZXI+DQogICAgPEFjdGl2aXR5Pg0KICAgICAgPElEPjU3MDM3NzU2PC9JRD4NCiAgICAgIDxTdGFydD4yNS8wOS8yMDIyIDE3OjA1PC9TdGFydD4NCiAgICAgIDxUeXBlPjY8L1R5cGU+DQogICAgICA8Q29kZT5EMTExMDwvQ29kZT4NCiAgICAgIDxRdWFudGl0eT4xPC9RdWFudGl0eT4NCiAgICAgIDxOZXQ+MjkxLjYwPC9OZXQ+DQogICAgICA8TGlzdD4yOTEuNjA8L0xpc3Q+DQogICAgICA8Q2xpbmljaWFuPkRIQS1QLTYwOTcyMjg1PC9DbGluaWNpYW4+DQogICAgICA8R3Jvc3M+MzI0PC9Hcm9zcz4NCiAgICAgIDxQYXRpZW50U2hhcmU+MzIuNDA8L1BhdGllbnRTaGFyZT4NCiAgICAgIDxQYXltZW50QW1vdW50PjI5MS42MDwvUGF5bWVudEFtb3VudD4NCiAgICA8L0FjdGl2aXR5Pg0KICA8L0NsYWltPg0KICA8Q2xhaW0+DQogICAgPElEPkExMDE5MTUgLSBESEEtRi0wMDQ3MDgxLkouU3ViLk9DVC0yMi5OLVJUQSAtIDI8L0lEPg0KICAgIDxJRFBheWVyPjY0NTkyMzItMjA1PC9JRFBheWVyPg0KICAgIDxQcm92aWRlcklEPkRIQS1GLTAwNDcwODE8L1Byb3ZpZGVySUQ+DQogICAgPFBheW1lbnRSZWZlcmVuY2U+QlQyMjEyMjgwNzY5NDk2NDwvUGF5bWVudFJlZmVyZW5jZT4NCiAgICA8RGF0ZVNldHRsZW1lbnQ+MjkvMTIvMjAyMiAwMDowMDwvRGF0ZVNldHRsZW1lbnQ+DQogICAgPENvbW1lbnRzPg0KICAgIDwvQ29tbWVudHM+DQogICAgPEVuY291bnRlcj4NCiAgICAgIDxGYWNpbGl0eUlEPkRIQS1GLTAwNDcwODE8L0ZhY2lsaXR5SUQ+DQogICAgPC9FbmNvdW50ZXI+DQogICAgPEFjdGl2aXR5Pg0KICAgICAgPElEPjU3MTk4MDE4PC9JRD4NCiAgICAgIDxTdGFydD4xOS8xMC8yMDIyIDIxOjAxPC9TdGFydD4NCiAgICAgIDxUeXBlPjY8L1R5cGU+DQogICAgICA8Q29kZT5EMDMzMDwvQ29kZT4NCiAgICAgIDxRdWFudGl0eT4xPC9RdWFudGl0eT4NCiAgICAgIDxOZXQ+MjkxLjYwPC9OZXQ+DQogICAgICA8TGlzdD4yOTEuNjA8L0xpc3Q+DQogICAgICA8Q2xpbmljaWFuPkRIQS1QLTAyNDg2MTU8L0NsaW5pY2lhbj4NCiAgICAgIDxHcm9zcz4zMjQ8L0dyb3NzPg0KICAgICAgPFBhdGllbnRTaGFyZT4zMi40MDwvUGF0aWVudFNoYXJlPg0KICAgICAgPFBheW1lbnRBbW91bnQ+MjkxLjYwPC9QYXltZW50QW1vdW50Pg0KICAgIDwvQWN0aXZpdHk+DQogIDwvQ2xhaW0+DQogIDxDbGFpbT4NCiAgICA8SUQ+RTEwNTA1NyAtIERIQS1GLTAwNDcwODEuSi5TdWIuT0NULTIyLk4tUlRBIC0gMzwvSUQ+DQogICAgPElEUGF5ZXI+NjQ1OTIzMi0yMDY8L0lEUGF5ZXI+DQogICAgPFByb3ZpZGVySUQ+REhBLUYtMDA0NzA4MTwvUHJvdmlkZXJJRD4NCiAgICA8UGF5bWVudFJlZmVyZW5jZT5CVDIyMTIyODA3Njk0OTY0PC9QYXltZW50UmVmZXJlbmNlPg0KICAgIDxEYXRlU2V0dGxlbWVudD4yOS8xMi8yMDIyIDAwOjAwPC9EYXRlU2V0dGxlbWVudD4NCiAgICA8Q29tbWVudHM+DQogICAgPC9Db21tZW50cz4NCiAgICA8RW5jb3VudGVyPg0KICAgICAgPEZhY2lsaXR5SUQ+REhBLUYtMDA0NzA4MTwvRmFjaWxpdHlJRD4NCiAgICA8L0VuY291bnRlcj4NCiAgICA8QWN0aXZpdHk+DQogICAgICA8SUQ+NTcxOTgwMTk8L0lEPg0KICAgICAgPFN0YXJ0PjE5LzEwLzIwMjIgMTk6MTA8L1N0YXJ0Pg0KICAgICAgPFR5cGU+NjwvVHlwZT4NCiAgICAgIDxDb2RlPkQxMTEwPC9Db2RlPg0KICAgICAgPFF1YW50aXR5PjE8L1F1YW50aXR5Pg0KICAgICAgPE5ldD4yOTEuNjA8L05ldD4NCiAgICAgIDxMaXN0PjI5MS42MDwvTGlzdD4NCiAgICAgIDxDbGluaWNpYW4+REhBLVAtMDE2NzcyMTwvQ2xpbmljaWFuPg0KICAgICAgPEdyb3NzPjMyNDwvR3Jvc3M+DQogICAgICA8UGF0aWVudFNoYXJlPjMyLjQwPC9QYXRpZW50U2hhcmU+DQogICAgICA8UGF5bWVudEFtb3VudD4yOTEuNjA8L1BheW1lbnRBbW91bnQ+DQogICAgPC9BY3Rpdml0eT4NCiAgPC9DbGFpbT4NCjwvUmVtaXR0YW5jZS5BZHZpY2U+=="
      file_content = Base64.decode64(response_body)
  
     # @xml_doc = Nokogiri::XML(file_content)
      # Rails.logger.info "Parsed XML: #{@xml_doc}"
      puts file_content

    rescue Savon::Error => e
      Rails.logger.error "SOAP Error for File ID #{file_id}: #{e.message}"
      nil
    end
  end
end
