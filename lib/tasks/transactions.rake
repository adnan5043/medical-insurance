namespace :transactions do
  desc "Process transactions for a given date range or with empty dates by default"
  task process: :environment do
    # Get `from_date` and `to_date` arguments
    from_date = ENV['FROM_DATE']
    to_date = ENV['TO_DATE']
    username = ENV['USER_NAME']

    if from_date.present? && to_date.present?
      from_date = Date.parse(from_date)
      to_date = Date.parse(to_date)
      puts "Processing transactions from #{from_date} to #{to_date}"
    elsif from_date.blank? && to_date.blank?
      # If no date range is provided, set both as `nil`
      from_date = nil
      to_date = nil
      puts "No date range provided. Sending empty date values."
    else
      puts "Both FROM_DATE and TO_DATE must be provided together or left blank for default behavior."
      exit
    end

    # Fetch all branches with login and password
    branches = if username.present?
                 Branch.where(username: username).pluck(:id, :username, :login, :password)
               else
                 Branch.pluck(:id, :username, :login, :password) 
               end

    if branches.empty?
      if username.present?
        puts "No branches found for user: #{username}"
      else
        puts "No branches found."
      end
      exit
    end

    branches.each do |branch|
      branch_id, username, login, password = branch
      puts "Processing transactions for branch: #{username}"

      # Prepare parameters for the job
      job_params = {
        login: login,
        password: password,
        transaction_from_date: from_date&.to_s,
        transaction_to_date: to_date&.to_s,
        direction: 2,
        transaction_id: 8,
        transaction_status: 1,
        min_record_count: -1,
        max_record_count: -1,
        sequence: [
          { direction: 2, transaction_id: 8, transaction_status: 2 },
          { direction: 1, transaction_id: 2, transaction_status: 1 },
          { direction: 1, transaction_id: 2, transaction_status: 2 }
        ]
      }

      # Check if a SearchTransaction exists for these parameters
      next if SearchTransaction.exists?(
        login: login,
        transaction_from_date: from_date,
        transaction_to_date: to_date
      )

      # Save a new SearchTransaction
      search_transaction = SearchTransaction.create!(
        login: login,
        transaction_from_date: from_date,
        transaction_to_date: to_date
      )

      # Queue the background job
      ProcessTransactionsJob.perform_later(job_params.merge(search_transaction_id: search_transaction.id))

      puts "Transaction job queued for branch: #{username} (ID: #{branch_id})"
    end

    puts "Transaction processing task completed."
  end
end
