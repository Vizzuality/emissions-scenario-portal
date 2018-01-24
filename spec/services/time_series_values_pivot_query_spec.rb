require 'rails_helper'

RSpec.describe TimeSeriesValuesPivotQuery do
  let(:paris1) { create(:scenario, name: 'Paris 1') }
  let(:poland) { create(:location, name: 'Poland') }
  let(:germany) { create(:location, name: 'Germany') }
  let(:cropland) { create(:indicator, name: 'Cropland') }
  let!(:time_series_values) do
    [
      create(:time_series_value, location: poland, indicator: cropland, year: 2010, scenario: paris1, value: 1),
      create(:time_series_value, location: germany, indicator: cropland, year: 2010, scenario: paris1, value: 2),
      create(:time_series_value, location: poland, indicator: cropland, year: 2020, scenario: paris1, value: 3),
      create(:time_series_value, location: germany, indicator: cropland, year: 2020, scenario: paris1, value: 4),
    ]
  end

  subject { TimeSeriesValuesPivotQuery.new(TimeSeriesValue.all).call }

  it 'should contain 2 rows' do
    expect(subject.count).to eq(2)
  end

  it 'should contain unit of entry' do
    expect(subject.first['unit_of_entry']).to eq(cropland.unit)
  end

  it 'should contain correct values' do
    results = TimeSeriesValuesPivotQuery.new(TimeSeriesValue.all).call
    expect(subject[0]['2010']).to eq('2.0')
    expect(subject[0]['2020']).to eq('4.0')
    expect(subject[1]['2010']).to eq('1.0')
    expect(subject[1]['2020']).to eq('3.0')
  end

  it 'should contain correct years' do
    expect(subject.years).to eq(['2010', '2020'])
  end
end
