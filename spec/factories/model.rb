FactoryGirl.define do
  factory :model do
    full_name { Faker::App.name }
    sequence(:abbreviation) { |n| full_name[0..5] + n.to_s }
    team
  end
end
