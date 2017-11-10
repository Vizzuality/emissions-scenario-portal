FactoryBot.define do
  factory :indicator do
    category 'Emissions'
    subcategory 'Emissions by sector'
    name 'Industry'
    stackable_subcategory true
    unit 'Gt CO2e/yr'
  end
end
