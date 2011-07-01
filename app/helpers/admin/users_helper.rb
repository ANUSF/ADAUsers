module Admin::UsersHelper
  def bool_to_s(var)
    var ? "Yes" : "No"
  end

  def signed_undertaking_form_to_s(signed_undertaking_form)
    ["No", "Yes", "Requested"][signed_undertaking_form || 0]
  end

  def user_roles_to_s(roles)
    roles.map {|ur| ur.roleID}.join(', ')
  end

  def link_to_delete_permission(user, datasetID, type, category)
    link_to send("admin_user_permissions_#{category}_path", user, datasetID, :type => type), :method => :delete do
      yield
    end
  end
end
