require 'spec_helper'

describe TemplatesHelper do
  it "renders templates" do
    t = Template.make(:body => "Test template. <%= 'z'*5 %>. <%= my_local %>. The end!")
    str = render_template(t.doc_type, t.name, :my_local => 'My local variable')

    str.should == "Test template. zzzzz. My local variable. The end!"
  end


  # -- Required when calling render_to_string in a testing context
  def controller_path
  end
  def action_name
  end
end
