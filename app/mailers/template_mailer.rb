class TemplateMailer < ActionMailer::Base
  default :from => Email::DEFAULT_FROM

  # Mail an email stored in an Email object
  def custom_email(email)
    mail(:from => email.from, :to => email.to, :subject => email.subject) do |format|
      format.html { render :text => email.body }
    end
  end

  def template_email(controller, to, template_name, locals)
    template = Template.find_by_doc_type_and_name('email', template_name)

    title = controller.render_template_field(template.title, locals)
    body = controller.render_template_field(template.body, locals)

    mail(:to => to, :subject => title) do |format|
      format.html { render :text =>  body}
    end
  end

end
