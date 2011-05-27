module TemplatesHelper
  def render_template(doc_type, name, locals={})
    t = Template.find_by_doc_type_and_name(doc_type, name)
    body = t ? t.body.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>') : ""

    render :inline => body, :locals => locals
  end
end
