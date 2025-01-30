class SettingsPolicy < ApplicationPolicy
  def index?
    user.allowed_permissions.include?("Settings")
  end
end
