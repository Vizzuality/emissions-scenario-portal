FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }

    trait :subcategory do
      association :parent, factory: :category
    end
  end
end

