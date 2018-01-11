require 'rails_helper'

RSpec.describe UploadTimeSeriesValues, upload: :s3 do
  let(:user) { create(:user) }
  let(:model) {
    create(:model, abbreviation: 'Model A', team: user.team)
  }
  let!(:scenario) {
    create(:scenario, name: 'Scenario 1', model: model)
  }
  let(:category) {
    create(:category, name: 'Emissions')
  }
  let(:subcategory) {
    create(:category, name: 'GHG Emissions by gas', parent: category, stackable: true)
  }
  let(:another_subcategory) {
    create(:category, name: 'GHG Emissions', parent: category, stackable: true)
  }
  let!(:indicator) {
    create(
      :indicator,
      category: category,
      subcategory: subcategory,
      name: 'CH4',
      unit: 'Mt CO2e/yr',
    )
  }
  let!(:note) {
    create(
      :note,
      model: model,
      indicator: indicator,
      unit_of_entry: "Mt CH4/yr",
      conversion_factor: 25
    )
  }
  let!(:location1) {
    create(:location, name: 'Poland', iso_code: 'PL')
  }
  let!(:location2) {
    create(:location, name: 'Portugal', iso_code: 'PT')
  }
  let(:csv_upload) {
    create(
      :csv_upload,
      user: user,
      model: model,
      service_type: 'UploadTimeSeriesValues',
      data: file
    )
  }

  subject { UploadTimeSeriesValues.new(csv_upload).call }

  context 'when file correct' do
    let(:file) {
      fixture_file_upload('files/time_series_values-correct.csv')
    }
    it 'should have saved all time series values' do
      expect { subject }.to change { TimeSeriesValue.count }.by(2)
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
      fixture_file_upload('files/time_series_values-correct.csv')
    }
    before(:each) do
      create(
        :time_series_value,
        scenario: scenario,
        indicator: indicator,
        location: location1,
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
      }.by(650)
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
      fixture_file_upload('files/time_series_values-invalid_column.csv')
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
      fixture_file_upload('files/time_series_values-unrecognised_scenario.csv')
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

  context 'when file with missing indicator' do
    let(:file) {
      fixture_file_upload('files/time_series_values-missing_indicator.csv')
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

  context 'when file with missing scenario' do
    let(:file) {
      fixture_file_upload('files/time_series_values-missing_scenario.csv')
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
      fixture_file_upload('files/time_series_values-incompatible_unit.csv')
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

  context 'when file with invalid value' do
    let(:file) {
      fixture_file_upload('files/time_series_values-invalid_value.csv')
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
      fixture_file_upload('files/time_series_values-correct.csv')
    }
    let(:csv_upload) {
      create(
        :csv_upload,
        user: create(:user),
        model: model,
        service_type: 'UploadTimeSeriesValues',
        data: file
      )
    }
    subject {
      UploadTimeSeriesValues.new(csv_upload).call
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

  context 'when csv with lower cased indicators given' do
    let!(:ieo) { create(:model, full_name: 'IEO', team: user.team) }

    let!(:reference) do
      create(:scenario, name: 'Reference', model: ieo)
    end

    let!(:electric_power) do
      create(
        :indicator,
        composite_name: 'Energy Related Emissions|Electric Power',
        unit: 'Mt CO2e/yr'
      )
    end

    let!(:pakistan) { create(:location, name: 'Pakistan') }

    let!(:csv_upload) do
      create(
        :csv_upload,
        user: user,
        model: ieo,
        data: fixture_file_upload('files/time_series_values-lowercase.csv'),
        service_type: 'UploadTimeSeriesValues'
      )
    end

    it 'should create TimeSeriesValues' do
      expect { subject }.to change { TimeSeriesValue.count }.by(3)
    end

    it 'should not create an new indicator' do
      expect { subject }.not_to change { Indicator.count }
    end
  end
end
