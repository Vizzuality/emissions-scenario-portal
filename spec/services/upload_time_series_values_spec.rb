require 'rails_helper'

RSpec.describe UploadTimeSeriesValues do
  let(:user) { FactoryGirl.create(:user) }
  let(:model) {
    FactoryGirl.create(:model, abbreviation: 'Model A', team: user.team)
  }
  let!(:scenario) {
    FactoryGirl.create(:scenario, name: 'Scenario 1', model: model)
  }
  let!(:indicator) {
    FactoryGirl.create(
      :indicator,
      category: 'Emissions',
      subcategory: 'GHG Emissions by gas',
      name: 'CH4',
      stackable_subcategory: true,
      unit: 'Mt CO2e/yr',
      unit_of_entry: 'Mt CH4/yr',
      conversion_factor: 25.0
    )
  }
  let!(:location) {
    FactoryGirl.create(:location, name: 'Poland')
  }
  subject { UploadTimeSeriesValues.new(user, model).call(file) }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-correct.csv'
        )
      )
    }
    it 'should have saved all rows' do
      expect { subject }.to change { TimeSeriesValue.count }.by(2)
    end
    it 'should have saved correct amounts' do
      expect { subject }.to change {
        indicator.time_series_values.sum(:value)
      }.by(30)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1) # 1 row with 2 values
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when file correct and overwrites old data' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-correct.csv'
        )
      )
    }
    before(:each) do
      FactoryGirl.create(
        :time_series_value,
        scenario: scenario,
        indicator: indicator,
        location: location,
        year: 2005,
        value: 100
      )
    end
    it 'should only have saved new rows' do
      expect { subject }.to change { TimeSeriesValue.count }.by(1)
    end
    it 'should have saved correct amounts' do
      expect { subject }.to change {
        indicator.time_series_values.sum(:value)
      }.by(-70)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1) # 1 row with 2 values
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when file with invalid column name' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-invalid_column.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when file with unrecognised scenario' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-unrecognised_scenario.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when file with incompatible unit' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-incompatible_unit.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when user without permissions' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-correct.csv'
        )
      )
    }
    subject {
      UploadTimeSeriesValues.new(FactoryGirl.create(:user), model).call(file)
    }
    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when duplicated indicator' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-correct.csv'
        )
      )
    }
    before(:each) {
      FactoryGirl.create(
        :indicator,
        category: indicator.category,
        subcategory: indicator.subcategory,
        name: indicator.name
      )
    }
    it 'should not have saved any rows' do
      expect { subject }.not_to(change { TimeSeriesValue.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end
end
