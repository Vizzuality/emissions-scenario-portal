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
      unit_of_entry: 'Mt CH4/yr',
      conversion_factor: 25.0
    )
  }
  let(:variation) {
    create(
      :indicator,
      parent: indicator,
      alias: "#{model.abbreviation} #{indicator.alias}",
      model: model,
      unit: indicator.unit,
      unit_of_entry: indicator.unit_of_entry,
      conversion_factor: indicator.conversion_factor
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
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-correct.csv'
        )
      )
    }
    it 'should have saved all time series values' do
      expect { subject }.to change { TimeSeriesValue.count }.by(2)
    end
    it 'should have created a variation' do
      expect { subject }.to change { indicator.variations.count }.by(1)
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
      create(
        :time_series_value,
        scenario: scenario,
        indicator: variation,
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
        variation.time_series_values.sum(:value)
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

  context 'when file with missing indicator' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-missing_indicator.csv'
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

  context 'when file with missing scenario' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-missing_scenario.csv'
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

  context 'when file with invalid value' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-invalid_value.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.to(change { TimeSeriesValue.count }.by(1))
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
      create(
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

  context 'when variation exists yet system indicator is used' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-system_instead_of_variation.csv'
        )
      )
    }
    before(:each) {
      variation
    }
    it 'should have saved values' do
      expect { subject }.to(change { TimeSeriesValue.count }.by(2))
    end
    it 'should have created values against variation' do
      expect { subject }.to(
        change { variation.time_series_values.count }.by(2)
      )
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when another model\'s team indicator matched' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-another_team_indicator.csv'
        )
      )
    }
    let(:other_model) { create(:model) }
    let!(:team_indicator) {
      create(
        :indicator,
        category: category,
        subcategory: another_subcategory,
        name: 'direct',
        unit: 'Mt CO2e/yr',
        unit_of_entry: 'Mt CH4/yr',
        conversion_factor: 25.0,
        alias: 'Emissions|GHG Emissions|direct',
        model: other_model,
        parent: nil
      )
    }
    it 'should have saved values' do
      expect { subject }.to(change { TimeSeriesValue.count }.by(2))
    end
    it 'should have turned team indicator into variation' do
      subject
      expect(team_indicator.reload.variation?).to be(true)
    end
    it 'should have created a new variation' do
      subject
      expect(team_indicator.reload.parent.variations.count).to eq(2)
    end
    it 'should have created values against new variation' do
      subject
      variation = Indicator.where(
        parent_id: team_indicator.reload.parent_id,
        alias: "#{model.abbreviation} #{team_indicator.alias}"
      ).first
      expect(variation.time_series_values.count).to eq(2)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when another model\'s variation matched' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'time_series_values-another_variation.csv'
        )
      )
    }
    let(:other_model) { create(:model, abbreviation: 'Model B') }
    let!(:variation) {
      create(
        :indicator,
        category: category,
        subcategory: another_subcategory,
        name: 'direct',
        unit: 'Mt CO2e/yr',
        unit_of_entry: 'Mt CH4/yr',
        conversion_factor: 25.0,
        alias: 'Model B Emissions|GHG Emissions|direct',
        model: other_model,
        parent: indicator
      )
    }
    it 'should have saved values' do
      expect { subject }.to(change { TimeSeriesValue.count }.by(2))
    end
    it 'should have created a new variation' do
      subject
      expect(variation.reload.parent.variations.count).to eq(2)
    end
    it 'should have created values against new variation' do
      subject
      variation = Indicator.where(
        parent_id: indicator.id,
        alias: "#{model.abbreviation} #{indicator.alias}"
      ).first
      expect(variation.time_series_values.count).to eq(2)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
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
        model: ieo,
        alias: 'Energy Related Emissions|Electric Power',
        unit: 'Mt CO2e/yr'
      )
    end

    let!(:pakistan) { create(:location, name: 'Pakistan') }

    let!(:csv_upload) do
      create(
        :csv_upload,
        user: user,
        model: ieo,
        data: File.open(
          Rails.root.join(
            'spec', 'fixtures', 'time_series_values-lowercase.csv'
          )
        ),
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
