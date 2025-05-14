# # app/services/python_smartcard_reader.rb
# class PythonSmartcardReader
#   def self.read_card
#     script_path = Rails.root.join('lib', 'python_scripts', 'smartcard_reader.py')
    
#     # Add debug output
#     Rails.logger.info "Executing Python script: #{script_path}"
    
#     output = `python3 #{script_path} 2>&1`
#     Rails.logger.info "Python script output: #{output}"
    
#     if $?.success?
#       result = parse_python_output(output)
#       Rails.logger.info "Parsed result: #{result}"
#       result
#     else
#       error_msg = "Failed to read card: #{output}"
#       Rails.logger.error error_msg
#       { error: error_msg }
#     end
#   rescue => e
#     error_msg = "Script execution error: #{e.message}"
#     Rails.logger.error error_msg
#     { error: error_msg }
#   end

#   private

#   def self.parse_python_output(output)
#     result = {}
    
#     output.each_line do |line|
#       case line.strip
#       when /Card Name:\s*(.+)/
#         result[:card_name] = $1.strip
#       when /Card Number:\s*(.+)/
#         result[:card_number] = $1.strip
#       when /Expiry Date:\s*(.+)/
#         result[:expiry_date] = $1.strip
#       when /Cardholder Name:\s*(.+)/
#         result[:cardholder_name] = $1.strip
#       end
#     end
    
#     if result.empty?
#       { error: "No card data found in output" }
#     else 
#       { data: result }
#     end
#   end
# end