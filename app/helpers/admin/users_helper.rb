module Admin::UsersHelper
  def bool_to_s(var)
    var ? "Yes" : "No"
  end

  def confirmed_acspri_member_to_s(acspri_member)
    ["No", "Yes", "Requested"][acspri_member || 0]
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
