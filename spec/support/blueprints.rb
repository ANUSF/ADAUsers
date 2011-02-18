require 'machinist/active_record'
require 'sham'

Sham.name       { Faker::Name.first_name }
Sham.email      { Faker::Internet.email }
Sham.password   { Faker::Lorem.sentence }


User.blueprint do
  user { Sham.name }
  password { Sham.password }
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


UserRole.blueprint do
  roleID { "affiliateusers" }
end

UserPermissionA.blueprint do
  userID { User.make.user }
  datasetID { AccessLevel.cat_a.first.datasetID }
  fileID { nil }
  permissionvalue { 1 }
end

AccessLevel.blueprint do
  datasetID { "au.edu.anu.assda.ddi.00001" }
  fileID { nil }
  datasetname { "Age Poll, July 1974" }
  fileContent { nil }
  accessLevel { "A" }
end

AccessLevel.blueprint(:with_fileContent) do
  datasetID { "au.edu.anu.assda.ddi.00115" }
  fileID { "F1" }
  datasetname { "00115/Disseminate/au.edu.anu.assda.ddi.00115.rtf" }
  fileContent "Description of images of Indigenous people in a sample of newspapers 1853-1897"
  accessLevel { "A" }
end
