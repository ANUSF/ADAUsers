module ApplicationHelper
  def ddi_to_id(ddi)
    ddi.gsub(".", "-")
  end
end
