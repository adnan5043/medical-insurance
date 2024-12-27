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
      member_id = claim.at_xpath('MemberID')&.text
      emirates_id_number = claim.at_xpath('EmiratesIDNumber')&.text
      claim_payer_id = claim.at_xpath('PayerID')&.text
      claim_gross = claim.at_xpath('Gross')&.text.to_f
      claim_patient_share = claim.at_xpath('PatientShare')&.text.to_f
      claim_net = claim.at_xpath('Net')&.text.to_f
      facility_id = claim.at_xpath('Encounter/FacilityID')&.text
      encounter_start = claim.at_xpath('Encounter/Start')&.text
      encounter_end = claim.at_xpath('Encounter/End')&.text
      encounter_type = claim.at_xpath('Encounter/Type')&.text.to_i
      encounter_start_type = claim.at_xpath('Encounter/StartType')&.text.to_i
      encounter_patient_id = claim.at_xpath('Encounter/PatientID')&.text
      diagnosis_type = claim.at_xpath('Diagnosis/Type')&.text
      diagnosis_code = claim.at_xpath('Diagnosis/Code')&.text
      


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
        denial_code = activity.at_xpath('DenialCode')&.text 


       # Extract Observation details (if present)
        observation_type = activity.at_xpath('Observation/Type')&.text
        observation_code = activity.at_xpath('Observation/Code')&.text
        observation_value = activity.at_xpath('Observation/Value')&.text
        observation_value_type = activity.at_xpath('Observation/ValueType')&.text

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
          member_id: member_id,
          emirates_id_number: emirates_id_number,
          claim_payer_id: claim_payer_id,
          claim_gross: claim_gross,
          claim_patient_share: claim_patient_share,
          claim_net: claim_net,
          encounter_start: encounter_start,
          encounter_end: encounter_end,
          encounter_type: encounter_type,
          encounter_start_type: encounter_start_type,
          encounter_patient_id: encounter_patient_id,
          diagnosis_type: diagnosis_type,
          diagnosis_code: diagnosis_code,
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
          data_type: data_type,
          observation_type: observation_type,
          observation_code: observation_code,
          observation_value: observation_value,
          observation_value_type: observation_value_type
        )
      end
    end
  end
end
