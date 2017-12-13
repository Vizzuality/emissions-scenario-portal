FactoryBot.define do
  factory :scenario do
    name { Faker::App.name }
    model
    published true
  end
end
