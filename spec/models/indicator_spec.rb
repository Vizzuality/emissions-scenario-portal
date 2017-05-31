require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it 'should be invalid when category not present' do
    expect(
      FactoryGirl.build(:indicator, category: nil)
    ).to have(1).errors_on(:category)
  end

  context 'linked scenarios and models' do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let(:scenario1) { FactoryGirl.create(:scenario) }
    let!(:scenario2) { FactoryGirl.create(:scenario) }
    let!(:time_series_value) {
      FactoryGirl.create(
        :time_series_value, indicator: indicator, scenario: scenario1
      )
    }
    it 'should return scenarios linked to this indicator' do
      expect(indicator.scenarios).to include(scenario1)
      expect(indicator.scenarios.length).to eq(1)
    end
    it 'should return modelslinked to this indicator' do
      expect(indicator.models).to include(scenario1.model)
      expect(indicator.models.length).to eq(1)
    end
  end

  describe :destroy do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let!(:time_series_value) {
      FactoryGirl.create(:time_series_value, indicator: indicator)
    }
    it 'should destroy all time series values' do
      expect { indicator.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
  end

  describe :find_all_by_slug do
    let!(:indicator1) {
      FactoryGirl.create(
        :indicator, category: 'A', subcategory: 'B', name: 'C'
      )
    }
    let!(:indicator2) {
      FactoryGirl.create(
        :indicator, category: 'A', subcategory: nil, name: 'B'
      )
    }
    it 'finds all indicators matching a 3-part slug' do
      expect(Indicator.find_all_by_slug('A|B|C')).to eq([indicator1])
    end
    it 'finds all indicators matching a 2-part slug' do
      expect(Indicator.find_all_by_slug('A|B')).to eq([indicator2])
    end
  end

  describe :time_series_data? do
    let!(:indicator) { FactoryGirl.create(:indicator) }
    it 'returns false when no time series data present' do
      expect(indicator.time_series_data?).to be(false)
    end
    it 'returns true when time series data present' do
      FactoryGirl.create(:time_series_value, indicator: indicator)
      expect(indicator.time_series_data?).to be(true)
    end
  end
end
