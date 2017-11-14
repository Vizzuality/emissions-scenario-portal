require 'rails_helper'

RSpec.describe CsvUploadJob do
  let(:team) { create(:team) }
  let(:user) { create(:user, team: team) }

  context 'time series values' do
    let!(:ieo) { create(:model, full_name: 'IEO', team: team) }
    let!(:gcam) { create(:model, full_name: 'GCAM', team: team) }

    let!(:reference) do
      create(:scenario, name: 'Reference', model: ieo)
    end
    let!(:gcam_reference) do
      create(:scenario, name: 'GCAM-Reference', model: gcam)
    end

    let!(:electric_power) do
      create(
        :indicator,
        model: ieo,
        alias: 'Energy Related Emissions|Electric Power',
        unit: 'Mt CO2e/yr'
      )
    end
    let!(:industry) do
      create(
        :indicator,
        model: ieo,
        alias: 'Emissions|CO2 by sector|Industry',
        unit: 'Mt CO2e/yr'
      )
    end

    let!(:usa) { create(:location, name: 'United States') }
    let!(:pakistan) { create(:location, name: 'Pakistan') }

    let!(:csv_upload) do
      create(
        :csv_upload,
        user: user,
        model: ieo,
        data: File.open(
          Rails.root.join(
            'spec', 'fixtures', 'time_series_values-data_example1.csv'
          )
        ),
        service_type: 'UploadTimeSeriesValues'
      )
    end

    it 'should create TimeSeriesValues' do
      expect do
        CsvUploadJob.perform_now(csv_upload.id)
      end.to change { TimeSeriesValue.count }.by(9)
    end

    it 'should overrwrite TimeSeriesValues' do
      CsvUploadJob.perform_now(csv_upload.id)

      expect do
        CsvUploadJob.perform_now(csv_upload.id)
      end.not_to change { TimeSeriesValue.count }
    end
  end
end
