require 'rails_helper'

RSpec.describe FilterLocations do
  let!(:zimbabwe) do
    create(:location, name: 'Zimbabwe', iso_code: 'ZW')
  end
  let!(:poland) do
    create(:location, name: 'Poland', iso_code: 'PL')
  end
  let!(:portugal) do
    create(:location, name: 'Portugal', iso_code: 'PT')
  end

  context 'when using search' do
    it 'searches by iso code' do
      expect(
        FilterLocations.new(search: 'PL').call(Location.all)
      ).to match_array([poland])
    end

    it 'searches by name' do
      expect(
        FilterLocations.new(search: 'pol').call(Location.all)
      ).to match_array([poland])
    end
  end

  context 'when sorting' do
    it 'orders by name' do
      expect(
        FilterLocations.new(order_type: 'name').call(Location.all)
      ).to eq([poland, portugal, zimbabwe])
    end

    it 'orders by iso code' do
      expect(
        FilterLocations.new(order_type: 'iso_code', order_direction: :desc).call(Location.all)
      ).to eq([zimbabwe, portugal, poland])
    end
  end
end
