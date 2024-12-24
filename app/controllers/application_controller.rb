class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :validate_recaptcha_for_login, if: :devise_login_action?

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
end
