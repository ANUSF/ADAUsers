# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


# -- Undertaking agreement
Template.create!(:doc_type => Template::DOC_TYPES[0],
                 :name => "undertaking_agreement",
                 :title => "Undertaking agreement",
                 :body => %q{<p>
  I HEREBY UNDERTAKE that I will use the data file(s)<br/>
  <br/>
  <% undertaking.dataset_descriptions.each do |dd| %>
    <%= dd %><br />
  <% end %>
</p>

<p>
  (hereinafter called 'the materials') supplied to me by the Australian Social Science Data Archives at the Australian National University for non-commercial research and educational purposes only, <strong>in accordance with and subject to the Conditions of Use set out below</strong>.<br/>
  <br/>
  I also consent to my name and institutional affiliation being provided to the data owners so they may collect information about the usage of their data and
 make contact with colleagues with similar interests.<br/>

  <% unless undertaking.user.institution_is_acspri_member %>
    <br/>
    I also undertake to meet the relevant charges for the materials.
  <% end %>
</p>


<h3>Conditions of Use</h3>

<p>
  I acknowledge that:
  <ol>
    <li>Use of the materials is restricted to non-commercial research and educational purposes only. The materials are not to be used for any other purpose without the express written permission of the Data Archive Manager.</li>
    <br/>
    <li>Use of the materials for the following purposes is not permitted:</li>
    <br/>
    <ol type="a">
      <li>transmitting or allowing access to the materials in part or whole to any other person / Department / Organisation not a party to this undertaking; and</li>
      <br/>
      <li>attempting to match the materials in whole or in part with any other information for the purposes of attempting to identify individuals, households or organisations.</li>
      <br/>
    </ol>
    <li>Outputs such as statistical tables, graphs, diagrams and interpretations obtained from my analysis of these materials may be further disseminated provided that I:</li>
    <br/>
    <ol type="a">
      <li>acknowledge both the original depositors and the Australian Social Science Data Archive;</li>
      <br/>
      <li>acknowledge another archive where the data file is made available through the Australian Social Science Data Archive by another archive;</li>
      <br/>
      <li>declare that those who carried out the original analysis and collection of the data bear no responsibility for the further analysis or interpretation of it; and</li>
      <br/>
      <li>provide ASSDA with the bibliographic details and, where available, online links to any published work (including journal articles, books or book chapters, conference presentations, theses or any other publications or outputs) based wholly or in part on the material.</li>
      <br/>
    </ol>
    <li>Use of the material is solely at my risk and I indemnify the Australian Social Science Data Archive and its host institutions including The Australian National University, the University of Technology, Sydney, The University of Queensland, University of Western Australia and University of Melbourne.</li>
    <br/>
    <li>The Australian Social Science Data Archive and its host institutions including The Australian National University, the University of Technology, Sydney, The University of Queensland, University of Western Australia and University of Melbourne shall not be held responsible for the accuracy and completeness of the material supplied.</li>
    <br/>
    <li>ASSDA should be notified of any errors discovered in the materials.</li>
    <br/>
    <li>At the conclusion of my research, any new data collections which have been derived from the materials supplied should be offered for deposit in the ASSDA collection. The deposit of the derived materials will include sufficient explanatory documentation to enable their use by others.</li>
    <br/>
    <li>At the conclusion of my research, all copies of the materials, including temporary copies, CDs, personal copies, back-ups, derived datasets and all electronic copies should be destroyed.</li>
  </ol>
  <br/>
</p>
})

# -- Email signature
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "signature_html",
                 :title => "",
                 :body => %q{<p>
  --<br />
  Australian Social Science Data Archive<br />
  Building 66, 18 Balmain Crescent<br />
  The Australian National University<br />
  Acton, ACT 0200 Australia<br />
  Telephone 61 2 6125 4400<br />
  Fax 61 2 6125 0627<br />
  Website: <%= link_to nil, root_url %><br />
</p>
})


# -- Study access approval
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "study_access_approval",
                 :title => 'Access approved for <%= category == :a ? "general" : "restricted" %> dataset(s)',
                 :body => %q{<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
<head></head>
<body>
  <p>Dear <%= user.name || user.user %>,</p>
  <p>You have now been granted access to the following dataset(s):</p>
  <p>
    <% datasets.each do |dataset| %>
      <%= dataset.dataset_description %>
    <% end %>
  </p>
  <p>Please refer to the Catalogue guide, which provides information on how to browse, analyse, visualise and download data.</p>

  <%= render_template 'email', 'signature_html' %>
</body>
</html>
})


# -- Registration
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "registration",
                 :title => "User Nesstar Registration",
                 :body => %q{Dear <%= user.name || user.user %>,

Thank you for registering with ASSDA's online Nesstar facility.
Your username and password are:

    Username: <%= user.user %>
    Password: <%= password %>

You can edit your details (including your email address), change your password,
and see which type of studies you currently have permission to access at
<%= edit_user_url(user) %>.

If you forget your password or username simply go to <%= reset_password_users_url %>,
submit your email address and we will email your login details to you.

Thank you for your time.

<%= render_template 'email', 'signature_html' %>})


# -- Change password
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "change_password",
                 :title => "ASSDA User Registration - password changed",
                 :body => %q{Dear <%= user.name || user.user %>,

Your ASSDA password has been updated.
Your new details are below:

Username: <%= user.user %>
Password: <%= new_password %>

If you forget your password or username go to the following webpage, supply your
email address and we will email your login to you:

<%= reset_password_users_url %>

If your email address changes please contact ASSDA at assda@anu.edu.au.
Thank you for your time.

<%= render_template 'email', 'signature_html' %>})


# -- Reset password
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "reset_password",
                 :title => "ASSDA User Password Reset",
                 :body => %q{Dear <%= user.name || user.user %>,

Someone (possibly you) requested a password reset for this account. If you'd like to do that,
please click on the link below and follow the instructions to change your password.

<%= reset_password_users_url(:token => user.token_reset_password) %>

If you do not wish to change your password, simply ignore this email.

<%= render_template 'email', 'signature_html' %>})


# -- Undertaking acknowledgement to admin
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "undertaking_acknowledgement_admin",
                 :title => '<%= undertaking.is_restricted ? "Restricted" : "General" %> undertaking form signed by <%= user.user %> (<%= user.institution_is_acspri_member ? "ACSPRI" : "Non-ACSPRI" %>)',
                 :body => %q{<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
  <head></head>
  <body>
    <%= undertaking.is_restricted ? "Restricted" : "General" %> undertaking form (<%= undertaking.user.institution_is_acspri_member ? "ACSPRI" : "Non-ACSPRI" %>) signed by <%= undertaking.user.user %><br />
    <br />
    The following datasets have been requested:<br />
    <br />
    <% undertaking.datasets.each do |dataset| %>
      <%= dataset.dataset_description %><br />
    <% end %>
    <br />
    To approve access see: <%= link_to nil, edit_admin_user_url(undertaking.user) %>
    <br />
    <br />
  </body>
</html>})


# -- Undertaking acknowledgement to user
Template.create!(:doc_type => Template::DOC_TYPES[1],
                 :name => "undertaking_acknowledgement_user",
                 :title => 'ASSDA <%= undertaking.is_restricted ? "Restricted" : "General" %> Undertaking',
                 :body => %q{<!DOCTYPE html PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<html>
  <head></head>
  <body>

    <p>
      Thank you for signing the ASSDA <%= undertaking.is_restricted ? "Restricted" : "General" %> Undertaking Agreement and requesting access to the data listed in the copy of the agreement below.

      <% if undertaking.user.institution_is_acspri_member %>
        Once your request has been processed, you will receive an acknowledgement email and will be given access to the data requested.
      <% else %>
        Once your request has been processed you will be invoiced, and notified by email when you have been given access to the data requested.
      <% end %>
    </p>

    <p>Please keep this email as a copy of the agreement:</p>
    <hr />
    <%= render_template 'page', 'undertaking_agreement', :locals => {:undertaking => undertaking} %>
    <br/>
    <%= render 'email', 'signature_html' %>
  </body>
</html>})
