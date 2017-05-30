require 'rails_helper'

RSpec.describe UploadTimeSeriesValues do
  let(:user) { FactoryGirl.create(:user) }
  let(:model) { FactoryGirl.create(:model, abbreviation: 'Model A') }
  let!(:scenario) {
    FactoryGirl.create(:scenario, name: 'Scenario 1', model: model)
  }
  let!(:indicator) {
    FactoryGirl.create(
      :indicator,
      category: 'Energy',
      subcategory: 'Energy use by fuel',
      name: 'Biomass w CSS',
      stackable_subcategory: true,
      unit: 'EJ/yr'
    )
  }
  let!(:location) {
    FactoryGirl.create(:location, name: 'Poland', iso_code2: 'PL')
  }
  subject { UploadTimeSeriesValues.new(user, model).call(file) }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'support',
          'time_series_values-correct.csv'
        )
      )
    }
    it 'should have saved all rows' do
      expect { subject }.to change { TimeSeriesValue.count }.by(2)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_rows_saved).to eq(1) # 1 row with 2 values
    end
    it 'should report no rows failed' do
      expect(subject.number_of_rows_failed).to eq(0)
    end
  end

  context 'when file with missing column' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'support',
          'time_series_values-missing_column.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(1)
    end
  end

  context 'when file with unrecognised scenario' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'support',
          'time_series_values-unrecognised_scenario.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(1)
    end
  end
end
