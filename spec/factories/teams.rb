FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "#{n} " + Faker::Team.name }
  end
end
