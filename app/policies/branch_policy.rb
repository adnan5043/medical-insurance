class BranchPolicy < ApplicationPolicy
  def index?
    user.allowed_permissions.include?("Branch")
  end
end
