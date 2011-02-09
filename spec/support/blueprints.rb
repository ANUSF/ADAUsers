require 'machinist/active_record'
require 'sham'

Sham.name       { Faker::Name.first_name }
Sham.email      { Faker::Internet.email }
Sham.password   { Faker::Lorem.sentence }

Sham.user_position { User.new.position_options[0] }
Sham.user_action { User.new.action_options[0][1] }
Sham.user_austinstitution { User.new.austinstitution_options[0][1] }
Sham.user_australian_uni { AustralianUni.first }


User.blueprint do
  user { Sham.name }
  password { Sham.password }
  fname { Sham.name }
  sname { Sham.name }
  email { Sham.email }
  position { Sham.user_position }
  action { Sham.user_action }
  country { User::AUSTRALIA }
  austinstitution { Sham.user_austinstitution }
  australian_uni { Sham.user_australian_uni }
end
