FactoryBot.define do
  factory :category do
    name { Faker::Pokemon.name }
  end
end

