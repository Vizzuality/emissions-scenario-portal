FactoryGirl.define do
  factory :model do
    sequence(:full_name) { |n| "#{n} " + Faker::App.name }
    abbreviation { full_name[0..10] }
    team
  end
end
