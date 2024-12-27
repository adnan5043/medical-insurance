class Transaction < ApplicationRecord
  validates :file_id, uniqueness: true

  # has_many :transaction_data, dependent: :destroy
  has_many :transaction_data, class_name: 'TransactionData', foreign_key: 'transaction_id'

  def save_transaction_data
    # Parse the XML content
    xml_doc = Nokogiri::XML(self.xml_content)
    
    # Debug: print the XML structure to see how it's parsed
    # puts xml_doc.to_xml
    # Extract Header data
    data_type = xml_doc.root.name

    header = xml_doc.at_xpath('//Header')
    sender_id = header.at_xpath('SenderID')&.text
    receiver_id = header.at_xpath('ReceiverID')&.text
    transaction_date = header.at_xpath('TransactionDate')&.text
    record_count = header.at_xpath('RecordCount')&.text.to_i
    disposition_flag = header.at_xpath('DispositionFlag')&.text

    # Iterate through Claims
    xml_doc.xpath('//Claim').each do |claim|
      claim_id = claim.at_xpath('ID')&.text
      id_payer = claim.at_xpath('IDPayer')&.text
      provider_id = claim.at_xpath('ProviderID')&.text
      payment_reference = claim.at_xpath('PaymentReference')&.text
      date_settlement = claim.at_xpath('DateSettlement')&.text
      comments = claim.at_xpath('Comments')&.text
      facility_id = claim.at_xpath('Encounter/FacilityID')&.text

      # Iterate through Activities within each Claim
      claim.xpath('Activity').each do |activity|
        activity_id = activity.at_xpath('ID')&.text
        activity_start = activity.at_xpath('Start')&.text
        activity_type = activity.at_xpath('Type')&.text.to_i
        activity_code = activity.at_xpath('Code')&.text
        activity_quantity = activity.at_xpath('Quantity')&.text.to_i
        activity_net = activity.at_xpath('Net')&.text.to_f
        activity_payment_amount = activity.at_xpath('PaymentAmount')&.text.to_f
        activity_clinician = activity.at_xpath('Clinician')&.text
        denial_code = activity.at_xpath('DenialCode')&.text # Extract DenialCode

        # Save activity-level data for each activity
        TransactionData.create!(
          transaction_id: self.id,
          file_id: self.file_id,
          sender_id: sender_id,
          receiver_id: receiver_id,
          transaction_date: transaction_date,
          record_count: record_count,
          disposition_flag: disposition_flag,
          claim_id: claim_id,
          id_payer: id_payer,
          provider_id: provider_id,
          payment_reference: payment_reference,
          date_settlement: date_settlement,
          comments: comments,
          facility_id: facility_id,
          activity_id: activity_id,
          activity_start: activity_start,
          activity_type: activity_type,
          activity_code: activity_code,
          activity_quantity: activity_quantity,
          activity_net: activity_net,
          activity_payment_amount: activity_payment_amount,
          activity_clinician: activity_clinician,
          denial_code: denial_code,
          data_type: data_type

        )
      end
    end
  end
end
