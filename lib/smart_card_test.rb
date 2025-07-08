require 'smartcard'

context = Smartcard::PCSC::Context.new
reader = context.readers.first
puts "Using reader: #{reader}"

card = nil

# Try connecting with T=0, fallback to T=1
begin
  card = Smartcard::PCSC::Card.new(context, reader, :shared, :t0)
  puts "Connected with protocol T=0"
rescue Smartcard::PCSC::Exception => e
  puts "T=0 failed, trying T=1..."
  card = Smartcard::PCSC::Card.new(context, reader, :shared, :t1)
  puts "Connected with protocol T=1"
end

# SELECT AID
select_aid = [0x00, 0xA4, 0x04, 0x00, 0x08,
              0xA0, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00].pack('C*')

begin
  response = card.transmit(select_aid)
  hex = response.unpack('H*').first.upcase
  puts "SELECT AID Response: #{hex}"

  if hex.end_with?("9000")
    puts "✅ AID selected successfully"
  elsif hex.start_with?("61")
    # This time, just dump and stop
    puts "ℹ️ Card is asking for #{hex[2..3]} bytes (possibly)"
  else
    puts "❌ Unexpected response to AID selection"
  end
rescue => e
  puts "AID select failed: #{e.message}"
end

# SELECT 1PAY.SYS.DDF01 (Visa/MasterCard PSE)
pse = [0x00, 0xA4, 0x04, 0x00, 0x0E] + "1PAY.SYS.DDF01".bytes
pse_cmd = pse.pack('C*')

begin
  response = card.transmit(pse_cmd)
  puts "PSE SELECT Response: #{response.unpack('H*').first.upcase}"
rescue => e
  puts "PSE SELECT failed: #{e.message}"
end

# Try GET RESPONSE with CLA = 0x80 instead of 0x00
get_response = [0x80, 0xC0, 0x00, 0x00, 0x1C].pack('C*')  # 0x1C = 28 bytes (from PSE)

begin
  response = card.transmit(get_response)
  puts "GET RESPONSE: #{response.unpack('H*').first.upcase}"
rescue => e
  puts "GET RESPONSE failed: #{e.message}"
end
# Dummy APDU: CLA=0x80, INS=0xCA (often used for GET DATA)
test_apdu = [0x80, 0xCA, 0x00, 0x00, 0x00].pack('C*')

begin
  response = card.transmit(test_apdu)
  puts "Dummy APDU Response: #{response.unpack('H*').first.upcase}"
rescue => e
  puts "Dummy APDU failed: #{e.message}"
end
