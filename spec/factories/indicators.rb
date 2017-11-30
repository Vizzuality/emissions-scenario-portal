FactoryBot.define do
  factory :indicator do
    association :category, factory: :category, name: 'Emissions'
    association :subcategory, factory: :category, name: 'Emissions by sector'
    name 'Industry'
    unit 'Gt CO2e/yr'
    sequence(:composite_name) { |n| [category&.name, subcategory&.name, "#{name}-#{n}"].join('|') }
  end
end
