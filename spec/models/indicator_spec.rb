require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it 'should be invalid when name not present' do
    expect(
      FactoryGirl.build(:indicator, name: nil)
    ).to have(1).errors_on(:name)
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
end
