require 'rails_helper'

RSpec.describe Scenario, type: :model do
  describe :meta_data? do
    let(:scenario) { FactoryGirl.create(:scenario) }
    it 'should be true when metadata present' do
      expect(scenario.meta_data?).to be(true)
    end
    pending 'should be false when some metadata absent'
  end
  describe :time_series_data? do
    let(:scenario) { FactoryGirl.create(:scenario) }
    it 'should be true when time series values present' do
      FactoryGirl.create(:time_series_value, scenario: scenario)
      expect(scenario.time_series_data?).to be(true)
    end
    it 'should be true when time series values absent' do
      expect(scenario.time_series_data?).to be(false)
    end
  end
end
