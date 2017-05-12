FactoryGirl.define do
  factory :indicator do
    category 'Emissions'
    stack_family 'Emissions by sector'
    name 'Industry'
    unit 'Gt CO2e/yr'
  end
end
