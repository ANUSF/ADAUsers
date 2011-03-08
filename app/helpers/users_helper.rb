module UsersHelper
  def acsprimember_to_s(acsprimember)
    ["No", "Yes", "Requested"][acsprimember]
  end

  def link_to_delete_permission(user, datasetID, type, category)
    link_to send("user_permissions_#{category}_path", user, datasetID, :type => type), :method => :delete do
      yield
    end
  end

  def build_australian_gov_options
    AustralianGov.types.map {|t| {t.name => t.members.map {|m| [m.name, m.id]}}}.reduce(:merge).reject {|k,v| k == ''}
  end
end
