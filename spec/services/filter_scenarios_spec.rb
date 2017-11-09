require 'rails_helper'

RSpec.describe FilterScenarios do
  context 'when using search' do
    it 'filters by category' do
      high_scenario_1 = create(:scenario, name: 'High 1')
      high_scenario_2 = create(:scenario, name: 'High 2')
      create(:scenario, name: 'Low')

      expect(
        FilterScenarios.
          new(search: 'high').
          call(Scenario.all)
      ).to match_array([high_scenario_1, high_scenario_2])
    end
  end

  context 'when sorting' do
    it 'orders by name' do
      high_scenario_1 = create(:scenario, name: 'High 1')
      high_scenario_2 = create(:scenario, name: 'High 2')

      expect(
        FilterScenarios.
          new(order_type: 'name', order_direction: 'desc').
          call(Scenario.all)
      ).to eq([high_scenario_2, high_scenario_1])
    end

    it 'orders by number of indicators' do
      with_2 = create(:scenario, name: 'with 2')
      create_list(:time_series_value, 2, scenario: with_2)
      without = create(:scenario, name: 'without')
      with_3 = create(:scenario, name: 'with 3')
      create_list(:time_series_value, 3, scenario: with_3)

      expect(
        FilterScenarios.
          new(order_type: 'indicators', order_direction: 'asc').
          call(Scenario.all)
      ).to eq([without, with_2, with_3])
    end

    it 'orders by time series' do
      with_2 = create(:scenario, name: 'with 2')
      create_list(:time_series_value, 2, scenario: with_2)
      without = create(:scenario, name: 'without')

      expect(
        FilterScenarios.
          new(order_type: 'time_series', order_direction: 'asc').
          call(Scenario.all)
      ).to eq([without, with_2])
    end
  end
end
