require 'rails_helper'

RSpec.describe FilterIndicators do
  let(:some_category) {
    create(:category, name: 'Energy')
  }
  let(:another_category) {
    create(:category, name: 'Emissions')
  }
  let(:some_subcategory) {
    create(:category, name: 'Energy use by fuel', parent: some_category)
  }
  let(:another_subcategory) {
    create(:category, name: 'CO2 by sector', parent: another_category)
  }
  let!(:biomass) do
    create(
      :indicator,
      subcategory: some_subcategory,
      name: 'Biomass'
    )
  end
  let!(:coal) do
    create(
      :indicator,
      subcategory: another_subcategory,
      name: 'Coal'
    )
  end

  context 'when using filters' do
    it 'filters by category' do
      expect(
        FilterIndicators.
          new(category: some_category.id.to_s).
          call(Indicator.all)
      ).to match_array([biomass])
    end
  end

  context 'when using text search' do
    it 'searches by category' do
      expect(
        FilterIndicators.
          new(search: 'Energy').
          call(Indicator.all)
      ).to match_array([biomass])
    end

    it 'searches by slug' do
      expect(
        FilterIndicators.
          new(search: 'Energy|Energy use by fuel|Biomass').
          call(Indicator.all)
      ).to match_array([biomass])
    end
  end

  context 'when sorting' do
    it 'orders by ESP name' do
      expect(
        FilterIndicators.
          new(order_type: 'esp_name', order_direction: 'ASC').
          call(Indicator.all)
      ).to eq([coal, biomass])
    end
  end
end
