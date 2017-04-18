FactoryGirl.define do
  factory :model do
    abbreviation { Faker::App.name[0..5] }
    full_name { Faker::App.name }
    team
  end
end
