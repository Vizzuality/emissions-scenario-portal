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
  let!(:system_indicator) do
    create(
      :indicator,
      category: some_category, subcategory: some_subcategory, name: 'Biomass'
    )
  end
  let(:team) { create(:team, name: 'AAA') }
  let(:other_team) { create(:team, name: 'BBB') }
  let(:model) { create(:model, full_name: 'AAA model', team: team) }
  let(:other_model) { create(:model, full_name: 'BBB model', team: other_team) }
  let!(:team_indicator) do
    create(
      :indicator,
      category: another_category, subcategory: another_subcategory, name: 'Industry',
      model: model,
      alias: 'Hello|My|Custom2'
    )
  end
  let!(:other_indicator) do
    create(
      :indicator,
      category: another_category, subcategory: another_subcategory, name: 'Transport',
      model: other_model,
      alias: 'Hello|My|Custom1'
    )
  end

  context 'when using filters' do
    it 'filters by category' do
      expect(
        FilterIndicators.
          new('category' => 'Energy').
          call(Indicator.all)
      ).to match_array([system_indicator])
    end

    it 'filters by type: system' do
      expect(
        FilterIndicators.
          new('type' => 'system').
          call(Indicator.all)
      ).to match_array([system_indicator])
    end

    it 'filters by type: team' do
      expect(
        FilterIndicators.
          new('type' => "team-#{team.id}").
          call(Indicator.all)
      ).to match_array([team_indicator])
    end
  end

  context 'when using text search' do
    it 'searches by category' do
      expect(
        FilterIndicators.
          new('search' => 'Energy').
          call(Indicator.all)
      ).to match_array([system_indicator])
    end

    it 'searches by slug' do
      expect(
        FilterIndicators.
          new('search' => 'Energy|Energy use by fuel|Biomass').
          call(Indicator.all)
      ).to match_array([system_indicator])
    end
  end

  context 'when sorting' do
    it 'orders by ESP name' do
      expect(
        FilterIndicators.
          new(order_type: 'esp_name', order_direction: 'ASC').
          call(Indicator.all)
      ).to eq([team_indicator, other_indicator, system_indicator])
    end

    it 'orders by model name' do
      b_variation = create(
        :indicator,
        parent: system_indicator,
        model: model,
        alias: 'B|My|Custom'
      )
      a_variation = create(
        :indicator,
        parent: system_indicator,
        model: model,
        alias: 'A|My|Custom'
      )

      expect(
        FilterIndicators.
          new(order_type: 'model_name', order_direction: 'DESC').
          call(Indicator.all)[0..1]
      ).to eq([b_variation, a_variation])
    end

    it 'orders by team who added it' do
      expect(
        FilterIndicators.
          new(order_type: 'added_by', order_direction: 'ASC').
          call(Indicator.all)
      ).to eq([team_indicator, other_indicator, system_indicator])
    end
  end
end
