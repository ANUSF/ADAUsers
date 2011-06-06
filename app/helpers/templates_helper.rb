module TemplatesHelper
  def render_template(doc_type, name, locals={})
    t = Template.find_by_doc_type_and_name(doc_type, name)
    body = t ? t.body.gsub(/\{\{/, '<%').gsub(/\}\}/, '%>') : ""

    method = defined?(render_to_string) ? :render_to_string : :render
    send(method, :inline => body, :locals => locals)
  end

  def render_template_field(str, locals)
    str.gsub!(/\{\{/, '<%').gsub!(/\}\}/, '%>')

    method = defined?(render_to_string) ? :render_to_string : :render
    send(method, :inline => str, :locals => locals)
  end
end
