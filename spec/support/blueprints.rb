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
  position { User.new.position_options[0] }
  action { User.new.action_options[0][1] }
  country { User::AUSTRALIA }
  austinstitution { User.new.austinstitution_options[0][1] }
  australian_uni { AustralianUni.first }
end
