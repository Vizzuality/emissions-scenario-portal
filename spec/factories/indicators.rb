FactoryBot.define do
  factory :indicator do
    association :category, factory: :category, name: 'Emissions'
    association :subcategory, factory: :category, name: 'Emissions by sector'
    sequence(:name) { |n| "Indicator-#{n}" }
    unit 'Gt CO2e/yr'
  end
end
