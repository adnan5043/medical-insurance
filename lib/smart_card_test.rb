require 'smartcard'

context = Smartcard::PCSC::Context.new
readers = context.readers

if readers.empty?
  puts "No smartcard readers found"
  exit
end

reader = readers.first
puts "Using reader: #{reader}"

card = Smartcard::PCSC::Card.new(context, reader, :shared, :t1)
puts "Card connected."

# Correct format for APDU command
uid_command = [0xFF, 0xCA, 0x00, 0x00, 0x00].pack('C*')

begin
  response = card.transmit(uid_command)
  uid_hex = response.unpack('H*').first.upcase
  puts "Card UID: #{uid_hex}"
rescue => e
  puts "Error reading UID: #{e.message}"
end
