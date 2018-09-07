require 'rails_helper'

RSpec.describe Api::V1::Data::EmissionPathways::CsvContent do
  include_context 'emission pathways'

  describe :call do
    it 'Replaces nulls with N/A' do
      filter = Api::V1::Data::EmissionPathways::Filter.new({})
      parsed_csv = CSV.parse(
        Api::V1::Data::EmissionPathways::CsvContent.new(filter).call
      )
      expect(parsed_csv.last.last).to eq('N/A')
    end
  end
end
