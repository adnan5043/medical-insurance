class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :validate_recaptcha_for_login, if: :devise_login_action?
  before_action :check_sidebar_permissions, unless: -> { devise_controller? || request.path == root_path }

  private

  # Check if the current action is a Devise login
  def devise_login_action?
    controller_name == 'sessions' && action_name == 'create'
  end

  # Validate reCAPTCHA for login
  def validate_recaptcha_for_login
    unless verify_recaptcha
      flash[:alert] = "reCAPTCHA verification failed. Please try again."
      # Redirect back to the login page
      redirect_to new_user_session_path and return
    end
  end

  def check_sidebar_permissions
    return unless current_user
    if current_user.allowed_permissions.include?("Full Access")
      return
    end
    permission_needed = case request.path
                        when transactions_path
                          "API Request"
                        when download_report_transactions_path
                          "Report"
                        when transaction_data_path
                          "Payment"
                        when admins_path
                          "Admin"
                        when settings_path
                          "Settings"
                        when patients_path
                          "Patient"
                        else
                          nil
                        end
    if permission_needed && !current_user.allowed_permissions.include?(permission_needed)
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
    end
  end
end
