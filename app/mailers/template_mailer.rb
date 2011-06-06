class TemplateMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  # Mail an email stored in an Email object
  def custom_email(email)
    mail(:from => email.from, :to => email.to, :subject => email.subject) do |format|
      format.html { render :text => email.body }
    end
  end

  def template_email(to, template_name, locals)
    template = Template.find_by_doc_type_and_name('email', template_name)

    mail(:to => to, :subject => render_template_field(template.title, locals)) do |format|
      format.html { render :text => render_template_field(template.body,  locals) }
    end
  end

end
