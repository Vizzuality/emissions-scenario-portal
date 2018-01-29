FactoryBot.define do
  factory :time_series_value do
    scenario
    indicator
    location
    sequence(:year) { |n| 2000 + n * 5 }
    value 10.0
  end
end
