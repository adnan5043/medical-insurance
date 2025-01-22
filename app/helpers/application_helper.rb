module ApplicationHelper
  def sidebar_permission?(page)
    current_user.allowed_permissions.include?(page)
  end
end
