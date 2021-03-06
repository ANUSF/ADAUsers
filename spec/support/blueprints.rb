require 'machinist/active_record'
require 'sham'

Sham.define do
  id         { |i| i }
  name       { Faker::Name.first_name }
  email      { Faker::Internet.email }
  password   { Faker::Lorem.sentence }
end


Country.blueprint do
  id
end

Country.blueprint(:australia) do
  Countryname { "Australia" }
  Sym { "AU" }
end

Country.blueprint(:new_zealand) do
  Countryname { "New Zealand" }
  Sym { "NZ" }
end

AUSTRALIA = Country.make :australia

User.blueprint do
  user { Sham.name }
  password { object.user*3 }
  title { User.new.title_options[0] }
  fname { Sham.name }
  sname { Sham.name }
  email { Sham.email }
  signed_undertaking_form { 1 }
  user_roles { [UserRole.where(:id => object.user, :roleID => RoleEjb.find_by_id("affiliateusers")).first ||
                UserRole.make(:id => object.user, :role => RoleEjb.find_by_id("affiliateusers"))] }
  role_cms { User::DEFAULT_ROLE_CMS }
  position { User.new.position_options[0] }
  action { User.new.action_options[0][1] }
  country { AUSTRALIA }
  austinstitution { User.new.austinstitution_options[0][1] }
  australian_uni { AustralianUni.first }
end

User.blueprint(:gov) do
  austinstitution { User.new.austinstitution_options[1][1] }
  australian_uni { nil }
  australian_gov { AustralianGov.first }
end

User.blueprint(:other_australian_affiliation) do
  austinstitution { User.new.austinstitution_options[2] }
  australian_uni { nil }
  institution { "Other Australian Institution" }
  institutiontype { User.new.other_aust_inst_types[0] }
end

User.blueprint(:foreign) do
  country { Country.find_by_Countryname("New Zealand") }
  austinstitution { nil }
  australian_uni { nil }
  australian_gov { nil }
  non_australian_affiliation { "My Institution" }
  non_australian_type { User.new.non_aust_inst_types[0] }
end

User.blueprint(:no_affiliation) do
  austinstitution { "" }
  australian_uni { nil }
end

User.blueprint(:administrator) do
  user { Sham.name }
  user_roles { [UserRole.make(:id => object.user, :role => RoleEjb.find_by_id("administrator"))] }
end

User.blueprint(:publisher) do
  user { Sham.name }
  user_roles { [UserRole.make(:id => object.user, :role => RoleEjb.find_by_id("publisher"))] }
end

UserRole.blueprint do
  role { RoleEjb.find_by_id("affiliateusers") }
end

RoleEjb.blueprint do
  id { "affiliateusers" }
  label { object.id }
  comment { object.id }
end

UserPermissionA.blueprint do
  userID { User.make.user }
  datasetID { AccessLevel.cat_a.first.datasetID }
  fileID { nil }
  permissionvalue { 1 }
end

UserPermissionB.blueprint do
  userID { User.make.user }
  datasetID { AccessLevel.cat_b.first.datasetID }
  fileID { nil }
  permissionvalue { 1 }
end

AccessLevel.blueprint do
  datasetID { "au.edu.anu.ada.ddi.%05d" % Sham.id }
  fileID { nil }
  datasetname { "Age Poll, July 1974, %d" % Sham.id }
  fileContent { nil }
  accessLevel { "A" }
end

AccessLevel.blueprint(:a) do
  accessLevel { "A" }
end

AccessLevel.blueprint(:b) do
  accessLevel { "B" }
end

AccessLevel.blueprint(:with_fileContent) do
  datasetID { "au.edu.anu.ada.ddi.%05d" % Sham.id }
  fileID { "F1" }
  datasetname { "00115/Disseminate/au.edu.anu.ada.ddi.%05d.rtf" % Sham.id }
  fileContent "Description of images of Indigenous people in a sample of newspapers 1853-1897"
  accessLevel { "A" }
end

AustralianUni.blueprint do
  id
  Longuniname { "Australian National University" }
  Shortuniname { "[ANU]" }
  acsprimember { 1 }
  g8 { 1 }
end

AustralianUni.blueprint(:melbourne) do
  id
  Longuniname { "University of Melbourne" }
  Shortuniname { "[MELBOURNE]" }
  acsprimember { 1 }
  g8 { 1 }
end

AustralianGov.blueprint do
  id
  value { "DEducation" }
  name { "Department of Education, Employment and Workplace Relations" }
  acsprimember { 1 }
  type { "Australian federal government department" }
end

AustralianGov.blueprint(:treasury) do
  value { "DTreasury" }
  name { "The Treasury" }
  acsprimember { 0 }
end

Undertaking.blueprint do
  user
  is_restricted false
  datasets { [AccessLevel.make] }
  intended_use_type ["government", "pure", "commercial", "thesis"]
  intended_use_other "other intended use"
  intended_use_description "intended use description"
  email_supervisor "email@supervisor.edu"
  funding_sources "funding sources"
  agreed false
  processed false
end

Template.blueprint do
  doc_type { Template::DOC_TYPES[0] }
  name { Sham.name }
  title { Sham.name }
  body { Sham.name }
end

Template.blueprint(:page) do
  doc_type { Template::DOC_TYPES[0] }
end

Template.blueprint(:email) do
  doc_type { Template::DOC_TYPES[1] }
end

AnuLog.blueprint do
  name { User.first || User.make }
  dataset { (AccessLevel.first || AccessLevel.make).datasetID }
  method_attr { "ANALIZE" }
  date_processed { Date.today }
end

AnuLog.blueprint(:analize) do
end

AnuLog.blueprint(:download) do
  method_attr { "DOWNLOAD" }
end
