FactoryGirl.define do
  factory :model do
    name { Faker::App.name }
    team
  end
end
