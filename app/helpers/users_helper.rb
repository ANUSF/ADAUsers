module UsersHelper
  def acsprimember_to_s(acsprimember)
    ["No", "Yes", "Requested"][acsprimember]
  end
end
