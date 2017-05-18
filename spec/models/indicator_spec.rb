require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it 'should be invalid when name not present' do
    expect(
      FactoryGirl.build(:indicator, name: nil)
    ).to have(1).errors_on(:name)
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
