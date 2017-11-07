require 'rails_helper'

RSpec.describe TimeSeriesValue, type: :model do
  it 'should be invalid when scenario not present' do
    expect(
      build(:time_series_value, scenario: nil)
    ).to have(1).errors_on(:scenario)
  end
  it 'should be invalid when indicator not present' do
    expect(
      build(:time_series_value, indicator: nil)
    ).to have(1).errors_on(:indicator)
  end
  it 'should be invalid when location not present' do
    expect(
      build(:time_series_value, location: nil)
    ).to have(1).errors_on(:location)
  end
  it 'should be invalid when year not present' do
    expect(
      build(:time_series_value, year: nil)
    ).to have(1).errors_on(:year)
  end
  it 'should be invalid when value not present' do
    expect(
      build(:time_series_value, value: nil)
    ).to have(1).errors_on(:value)
  end
  describe :fetch_all do
    let(:scenario1) {
      create(:scenario, name: 'XYZ')
    }
    let(:scenario2) {
      create(:scenario, name: 'ABC')
    }
    let(:location1) {
      create(:location, name: '123')
    }
    let(:location2) {
      create(:location, name: '789')
    }
    let(:indicator) {
      create(:indicator)
    }
    let!(:time_series_value1) {
      create(
        :time_series_value,
        indicator: indicator, scenario: scenario1, location: location1,
        year: 2005, value: 20
      )
    }
    let!(:time_series_value2) {
      create(
        :time_series_value,
        indicator: indicator, scenario: scenario2, location: location2,
        year: 2005, value: 30
      )
    }
    context 'when using text search' do
      it 'searches by location name' do
        expect(
          TimeSeriesValue.fetch_all(
            indicator.time_series_values, 'search' => '123'
          )[:data].map { |tsv| tsv[:location_name] }
        ).to match_array([location1.name])
      end
      it 'searches by scenario name' do
        expect(
          TimeSeriesValue.fetch_all(
            indicator.time_series_values, 'search' => 'ABC'
          )[:data].map { |tsv| tsv[:scenario_name] }
        ).to match_array([scenario2.name])
      end
    end
    context 'when sorting' do
      it 'orders by location' do
        expect(
          TimeSeriesValue.fetch_all(
            indicator.time_series_values, 'order_type' => 'location_name'
          )[:data].map { |tsv| tsv[:location_name] }
        ).to eq([location1.name, location2.name])
      end
      it 'orders by scenario' do
        expect(
          TimeSeriesValue.fetch_all(
            indicator.time_series_values, 'order_type' => 'scenario_name'
          )[:data].map { |tsv| tsv[:scenario_name] }
        ).to eq([scenario2.name, scenario1.name])
      end
    end
  end
end
