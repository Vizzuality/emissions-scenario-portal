FactoryGirl.define do
  factory :time_series_value do
    scenario
    indicator
    location
    year 2017
    value 10.0
  end
end