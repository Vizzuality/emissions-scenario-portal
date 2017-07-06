require 'rails_helper'

RSpec.describe Indicator, type: :model do
  it 'should be invalid when category not present' do
    expect(
      FactoryGirl.build(:indicator, category: nil)
    ).to have(1).errors_on(:category)
  end

  context 'linked scenarios and models' do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let(:scenario1) { FactoryGirl.create(:scenario) }
    let!(:scenario2) { FactoryGirl.create(:scenario) }
    let!(:time_series_value) {
      FactoryGirl.create(
        :time_series_value, indicator: indicator, scenario: scenario1
      )
    }
    it 'should return scenarios linked to this indicator' do
      expect(indicator.scenarios).to include(scenario1)
      expect(indicator.scenarios.length).to eq(1)
    end
    it 'should return modelslinked to this indicator' do
      expect(indicator.models).to include(scenario1.model)
      expect(indicator.models.length).to eq(1)
    end
  end

  describe :scope do
    let(:model) { FactoryGirl.create(:model) }
    let(:system_indicator) {
      FactoryGirl.create(:indicator, parent: nil, model: nil)
    }
    let(:team_indicator) {
      FactoryGirl.create(:indicator, parent: nil, model: model)
    }
    let(:team_variation) {
      FactoryGirl.create(:indicator, parent: system_indicator, model: model)
    }
    it 'is a system indicator' do
      expect(system_indicator.scope).to eq(:system_indicator)
    end
    it 'is a team indicator' do
      expect(team_indicator.scope).to eq(:team_indicator)
    end
    it 'is a team variation' do
      expect(team_variation.scope).to eq(:team_variation)
    end
  end

  context 'variations' do
    let(:model) { FactoryGirl.create(:model) }
    let(:system_indicator) {
      FactoryGirl.create(:indicator, parent: nil, model: nil)
    }
    let(:team_variation) {
      FactoryGirl.create(:indicator, parent: system_indicator, model: model)
    }
    describe :variation? do
      it 'is a team variation' do
        expect(team_variation.variation?).to be(true)
      end
    end
    it 'should be invalid if model not present' do
      expect(
        FactoryGirl.build(:indicator, parent: system_indicator, model: nil)
      ).to have(1).errors_on(:model)
    end
  end

  describe :destroy do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let!(:time_series_value) {
      FactoryGirl.create(:time_series_value, indicator: indicator)
    }
    it 'should destroy all time series values' do
      expect { indicator.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
  end

  describe :slug_to_hash do
    let!(:indicator1) {
      FactoryGirl.create(
        :indicator, category: 'A', subcategory: 'B', name: 'C'
      )
    }
    let!(:indicator2) {
      FactoryGirl.create(
        :indicator, category: 'A', subcategory: nil, name: 'B'
      )
    }
    it 'parses a 3-part slug' do
      expect(
        Indicator.slug_to_hash('A|B|C')
      ).to eq(category: 'A', subcategory: 'B', name: 'C')
    end
    it 'parses a 3-part slug with blank subcategory' do
      expect(
        Indicator.slug_to_hash('A||B')
      ).to eq(category: 'A', subcategory: '', name: 'B')
    end
    it 'parses a 2-part slug' do
      expect(
        Indicator.slug_to_hash('A|B')
      ).to eq(category: 'A', subcategory: 'B')
    end
  end

  describe :time_series_data? do
    let!(:indicator) { FactoryGirl.create(:indicator) }
    it 'returns false when no time series data present' do
      expect(indicator.time_series_data?).to be(false)
    end
    it 'returns true when time series data present' do
      FactoryGirl.create(:time_series_value, indicator: indicator)
      expect(indicator.time_series_data?).to be(true)
    end
  end

  describe :for_model do
    let(:model1) { FactoryGirl.create(:model) }
    let(:model2) { FactoryGirl.create(:model) }
    let!(:core_indicator1) { FactoryGirl.create(:indicator) }
    let!(:core_indicator2) { FactoryGirl.create(:indicator) }
    let!(:model_indicator) {
      FactoryGirl.create(:indicator, parent: core_indicator1, model: model1)
    }
    it 'returns only core indicators for model without model indicators' do
      expect(Indicator.for_model(model2)).to match_array(
        [core_indicator1, core_indicator2]
      )
    end
    it 'returns core and model indicators for model with model indicators' do
      expect(Indicator.for_model(model1)).to match_array(
        [model_indicator, core_indicator2]
      )
    end
  end

  describe :scenarios do
    let(:indicator) { FactoryGirl.create(:indicator) }
    let(:scenario) { FactoryGirl.create(:scenario) }
    let!(:time_series_value1) {
      FactoryGirl.create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    let!(:time_series_value2) {
      FactoryGirl.create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    it 'should not double count' do
      expect(indicator.scenarios.count).to eq(1)
    end
  end

  describe :fetch_all do
    let!(:indicator1) {
      FactoryGirl.create(
        :indicator,
        category: 'Energy', subcategory: 'Energy use by fuel', name: 'Biomass'
      )
    }
    let(:model) {
      FactoryGirl.create(:model)
    }
    let!(:indicator2) {
      FactoryGirl.create(
        :indicator,
        category: 'Emissions', subcategory: 'CO2 by sector', name: 'Industry',
        model: model
      )
    }
    context 'when using filters' do
      it 'filters by category' do
        expect(
          Indicator.fetch_all('category' => 'Energy')
        ).to match_array([indicator1])
      end
      it 'filters by type: core' do
        expect(
          Indicator.fetch_all('type' => 'core')
        ).to match_array([indicator1])
      end
      it 'filters by type: team' do
        expect(
          Indicator.fetch_all('type' => "team-#{model.team_id}")
        ).to match_array([indicator2])
      end
    end
    context 'when using text search' do
      it 'searches by category' do
        expect(
          Indicator.fetch_all('search' => 'Energy')
        ).to match_array([indicator1])
      end
      it 'searches by slug' do
        expect(
          Indicator.fetch_all('search' => 'Emissions|CO2 by sector|Industry')
        ).to match_array([indicator2])
      end
    end
    context 'when sorting' do
      it 'orders by name' do
        expect(
          Indicator.fetch_all('order_type' => 'name')
        ).to eq([indicator1, indicator2])
      end
      it 'orders by slug' do
        expect(
          Indicator.fetch_all('order_type' => 'alias')
        ).to eq([indicator2, indicator1])
      end
    end
  end
end
