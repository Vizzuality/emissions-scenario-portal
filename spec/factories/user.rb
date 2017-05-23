FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    admin false
    team
    password { Faker::Internet.password }
  end
end
