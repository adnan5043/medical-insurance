module TransactionsHelper

	def get_last_transaction_at
		message = ""

		branches = Branch.all
		branches.each do |branch|

			user = branch.username
			td = TransactionData.where("sender_id = ? OR receiver_id = ?", branch.clinical_id, branch.clinical_id).last
			transaction = td.transaction_record
			request_by = transaction.search_transaction.nil? ? 'By System' : 'By Mannual Request'

			message += "<span class='text-warning'>#{user}</span> Clinic Last Updated At: <span class='text-warning'>#{transaction.created_at}</span> #{request_by} <br>"

		end
		message.html_safe

	end

end
