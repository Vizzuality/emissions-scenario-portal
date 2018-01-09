require 'rails_helper'

RSpec.describe FilterScenarios do
  context 'when using search' do
    it 'filters by category' do
      high1 = create(:scenario, name: 'High 1')
      high2 = create(:scenario, name: 'High 2')
      create(:scenario, name: 'Low')

      expect(
        FilterScenarios.
          new(search: 'high').
          call(Scenario.all)
      ).to match_array([high1, high2])
    end
  end

  context 'when sorting' do
    it 'orders by name' do
      high1 = create(:scenario, name: 'High 1')
      high2 = create(:scenario, name: 'High 2')

      expect(
        FilterScenarios.
          new(order_type: 'name', order_direction: 'desc').
          call(Scenario.all)
      ).to eq([high2, high1])
    end

    it 'orders by number of indicators' do
      with2 = create(:scenario, name: 'with 2')
      create_list(:time_series_value, 2, scenario: with2)
      without = create(:scenario, name: 'without')
      with3 = create(:scenario, name: 'with 3')
      create_list(:time_series_value, 3, scenario: with3)

      expect(
        FilterScenarios.
          new(order_type: 'indicators', order_direction: 'asc').
          call(Scenario.all)
      ).to eq([without, with2, with3])
    end

    it 'orders by time series values count' do
      with2 = create(:scenario, name: 'with 2')
      create_list(:time_series_value, 2, scenario: with2)
      without = create(:scenario, name: 'without')

      expect(
        FilterScenarios.
          new(order_type: 'time_series_values_count', order_direction: 'asc').
          call(Scenario.all)
      ).to eq([without, with2])
    end
  end
end
