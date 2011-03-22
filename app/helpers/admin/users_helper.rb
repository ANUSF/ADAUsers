module Admin::UsersHelper
  def acsprimember_to_s(acsprimember)
    ["No", "Yes", "Requested"][acsprimember]
  end

  def link_to_delete_permission(user, datasetID, type, category)
    link_to send("admin_user_permissions_#{category}_path", user, datasetID, :type => type), :method => :delete do
      yield
    end
  end
end
