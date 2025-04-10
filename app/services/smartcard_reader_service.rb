require 'smartcard'

class SmartcardReaderService
  def self.read_card
    Rails.logger.info "Initializing smart card context..."
    context = Smartcard::PCSC::Context.new
    readers = context.readers

    if readers.empty?
      Rails.logger.error "No smart card readers found."
      return { error: "No smart card reader found" }
    end

    Rails.logger.info "Found readers: #{readers.inspect}"
    
    reader_name = readers.first
    Rails.logger.info "Using reader: #{reader_name.inspect}"

    begin
      card = Smartcard::PCSC::Card.new(context, reader_name, :exclusive, :t1)  
      Rails.logger.info "Connected to card."

      # Step 1: Select Master File (MF) or an Application (Modify as needed)
      select_command = [0x00, 0xA4, 0x04, 0x00, 0x00]  # Select command
      Rails.logger.info "Sending SELECT FILE command: #{select_command.pack('C*').unpack('H*').first}"
      response = card.transmit(select_command.pack("C*"))
      response_data = response.unpack("C*")
      
      sw1, sw2 = response_data[-2], response_data[-1]
      Rails.logger.info "SELECT FILE Response SW1 SW2: #{format('%02X', sw1)} #{format('%02X', sw2)}"

      if sw1 != 0x90 || sw2 != 0x00
        Rails.logger.error "Failed to select file. SW1 SW2: #{format('%02X', sw1)} #{format('%02X', sw2)}"
        return { error: "Failed to select file", sw1: sw1, sw2: sw2 }
      end

      # Step 2: Try reading 16 bytes or adjust based on file structure
      read_command = [0x00, 0xA4, 0x04, 0x00, 0x00] # Adjust read command as necessary
      Rails.logger.info "Sending READ BINARY command: #{read_command.pack('C*').unpack('H*').first}"
      response = card.transmit(read_command.pack("C*"))
      response_data = response.unpack("C*")

      sw1, sw2 = response_data[-2], response_data[-1]
      Rails.logger.info "READ BINARY Response SW1 SW2: #{format('%02X', sw1)} #{format('%02X', sw2)}"

      if sw1 == 0x90 && sw2 == 0x00
        if response_data.length > 2  
          card_data_bytes = response_data[0...-2]  # Extract data

          # Convert to ASCII and sanitize null bytes
          card_data_ascii = card_data_bytes.pack("C*").force_encoding("UTF-8").scrub("").delete("\x00")
          card_data_hex = card_data_bytes.pack("C*").unpack1("H*")

          Rails.logger.info "Data (ASCII): #{card_data_ascii}"
          Rails.logger.info "Data (HEX): #{card_data_hex}"
          Rails.logger.info "Length: #{card_data_bytes.length}"

          # Parse the data
          parsed_data = parse_smartcard_data(card_data_hex)

          return { success: true, data: card_data_ascii, hex_data: card_data_hex, length: card_data_bytes.length, parsed_data: parsed_data }
        else
          Rails.logger.info "No data found."
          return { success: false, message: "No data found." }
        end
      else
        # Detailed logging for failure
        Rails.logger.error "Smartcard read failed. SW1 SW2: #{format('%02X', sw1)} #{format('%02X', sw2)}"
        
        # Suggest retry with different commands if necessary
        if sw1 == 0x6D
          Rails.logger.error "Command is not supported. Check if a different command is required."
        end
        
        return { error: "Smartcard read failed", sw1: sw1, sw2: sw2 }
      end
    rescue Smartcard::PCSC::Exception => e
      Rails.logger.error "Smartcard read error: #{e.message} (Code: #{e.code})"
      return { error: e.message }
    ensure
      card.disconnect(:leave)
    end
  end

  private
def self.parse_smartcard_data(hex_data)
  # Example parsing logic (adjust based on your smart card's data structure)
  parsed_data = {}

  # Assuming the first 16 bytes represent a header (adjust if needed)
  parsed_data[:header] = hex_data[0..15]

  # Example: Parsing the next 16 bytes for EMIRATE ID (this is based on your data format)
  parsed_data[:emirate_id] = hex_data[16..31]

  # Assuming the data after that represents some other information (e.g., patient's name, etc.)
  # Adjust the slice and interpretation as per your card's specification
  parsed_data[:additional_info] = hex_data[32..47]

  # If the data contains specific tags or identifiers, you can extract them accordingly.
  parsed_data
end

end