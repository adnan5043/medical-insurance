namespace :api_request do
  desc "Send API request daily at a specific time"
  task hit_api: :environment do
    Rails.logger.info "Starting daily API request..."
    Branch.all.each do |branch|
      transaction_from_date = 7.days.ago.to_date
      transaction_to_date = Date.today

      if branch.login.blank? || branch.password.blank?
        Rails.logger.warn "No login or password found for branch #{branch.id}. Skipping."
        next
      end
      params = {
        username: branch.login,  
        password: branch.password, 
        transaction_from_date: transaction_from_date,
        transaction_to_date: transaction_to_date
      }

      ProcessTransactionsJob.perform_later(params) 
      Rails.logger.info "API request sent for branch #{branch.id} with login #{branch.login}"
    end

    Rails.logger.info "Daily API request completed."
  end
end
