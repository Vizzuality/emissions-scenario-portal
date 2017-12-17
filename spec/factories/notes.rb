FactoryBot.define do
  factory :note do
    model
    indicator
    description "my description"
    unit_of_entry "GW"
    conversion_factor 1.0
  end
end
