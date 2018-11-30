require 'rails_helper'

RSpec.describe Api::V1::Data::EmissionPathways::CsvContent do
  include_context 'emission pathways'

  before(:each) do
    SearchableTimeSeriesValue.refresh
  end

  describe :call do
    it 'Replaces nulls with N/A' do
      filter = Api::V1::Data::EmissionPathways::Filter.new({})
      parsed_csv = CSV.parse(
        Api::V1::Data::EmissionPathways::CsvContent.new(filter).call
      )
      # The position 9 is the one for year 2030
      expect(parsed_csv.last[9]).to eq('N/A')
    end
  end
end
