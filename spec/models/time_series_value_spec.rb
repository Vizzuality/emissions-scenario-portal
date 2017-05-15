require 'rails_helper'

RSpec.describe TimeSeriesValue, type: :model do
  it 'should be invalid when scenario not present' do
    expect(
      FactoryGirl.build(:time_series_value, scenario: nil)
    ).to have(1).errors_on(:scenario)
  end
  it 'should be invalid when indicator not present' do
    expect(
      FactoryGirl.build(:time_series_value, indicator: nil)
    ).to have(1).errors_on(:indicator)
  end
  it 'should be invalid when year not present' do
    expect(
      FactoryGirl.build(:time_series_value, year: nil)
    ).to have(1).errors_on(:year)
  end
  it 'should be invalid when value not present' do
    expect(
      FactoryGirl.build(:time_series_value, value: nil)
    ).to have(1).errors_on(:value)
  end
end
