require 'machinist/active_record'
require 'sham'

Sham.define do
  id         { |i| i }
  name       { Faker::Name.first_name }
  email      { Faker::Internet.email }
  password   { Faker::Lorem.sentence }
end


User.blueprint do
  user { Sham.name }
  password { Sham.password }
  title { User.new.title_options[0] }
  fname { Sham.name }
  sname { Sham.name }
  email { Sham.email }
  acsprimember { 1 }
  user_roles { [UserRole.make(:id => object.id)] }
  position { User.new.position_options[0] }
  action { User.new.action_options[0][1] }
  country { User::AUSTRALIA }
  austinstitution { User.new.austinstitution_options[0][1] }
  australian_uni { AustralianUni.first }
end

User.blueprint(:no_affiliation) do
  austinstitution { "" }
  australian_uni { nil }
end

User.blueprint(:administrator) do
  user_roles { [UserRole.make(:id => object.id, :role => RoleEjb.find_by_id("administrator"))] }
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

AccessLevel.blueprint do
  datasetID { "au.edu.anu.assda.ddi.%05d" % Sham.id }
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
  datasetID { "au.edu.anu.assda.ddi.%05d" % Sham.id }
  fileID { "F1" }
  datasetname { "00115/Disseminate/au.edu.anu.assda.ddi.%05d.rtf" % Sham.id }
  fileContent "Description of images of Indigenous people in a sample of newspapers 1853-1897"
  accessLevel { "A" }
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

AustralianUni.blueprint do
  id
  Longuniname { "Australian National University" }
  Shortuniname { "[ANU]" }
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
