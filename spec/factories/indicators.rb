FactoryBot.define do
  factory :indicator do
    association :subcategory, factory: [:category, :subcategory], name: 'Emissions by sector'
    sequence(:name) { |n| "Indicator-#{n}" }
    unit 'Gt CO2e/yr'
  end
end
