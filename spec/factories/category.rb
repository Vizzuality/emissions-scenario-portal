FactoryBot.define do
  factory :category do
    name { Faker::Pokemon.unique.name }

    trait :subcategory do
      association :parent, factory: :category
    end
  end
end

