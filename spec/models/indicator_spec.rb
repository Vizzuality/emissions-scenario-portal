require 'rails_helper'

RSpec.describe Indicator, type: :model do
  context 'validations' do
    it 'should be invalid when category not present' do
      expect(
        build(:indicator, category: nil)
      ).to have(1).errors_on(:category)
    end

    it 'should be invalid when alias already exists within model and parent' do
      indicator = create(:indicator)
      expect(
        build(
          :indicator,
          alias: indicator.alias,
          model: indicator.model,
          parent: indicator.parent
        )
      ).to have(1).errors_on(:alias)
    end

    it 'should be invalid when references self as a parent' do
      indicator = build(:indicator)
      indicator.parent = indicator
      expect(indicator).to have(1).errors_on(:parent)
    end
  end

  context 'linked scenarios and models' do
    let(:indicator) { create(:indicator) }
    let(:scenario1) { create(:scenario) }
    let!(:scenario2) { create(:scenario) }
    let!(:time_series_value) {
      create(
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
    let(:model) { create(:model) }
    let(:system_indicator) {
      create(:indicator, parent: nil, model: nil)
    }
    let(:team_indicator) {
      create(:indicator, parent: nil, model: model)
    }
    let(:team_variation) {
      create(
        :indicator,
        parent: system_indicator, model: model, unit: system_indicator.unit
      )
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
    let(:model) { create(:model) }
    let(:system_indicator) {
      category = create(
        :category,
        name: 'Buildings'
      )
      create(
        :indicator, parent: nil, model: nil, category: category
      )
    }
    let(:team_variation) {
      category = create(
        :category,
        name: 'Transportation'
      )
      create(
        :indicator,
        parent: system_indicator, model: model, category: category,
        unit: system_indicator.unit
      )
    }
    describe :variation? do
      it 'is a team variation' do
        expect(team_variation.variation?).to be(true)
      end
    end
    it 'should be invalid if model not present' do
      expect(
        build(:indicator, parent: system_indicator, model: nil)
      ).to have(1).errors_on(:model)
    end
    it 'should be invalid if parent is a variation' do
      expect(
        build(:indicator, parent: team_variation, model: model)
      ).to have(1).errors_on(:parent)
    end
    describe :update_category do
      it 'updates category to match parent' do
        expect(team_variation.category.name).to eq('Buildings')
      end
    end
  end

  context 'forking system indicators from team indicators' do
    let(:model) { create(:model) }
    let(:other_model) { create(:model) }
    let!(:team_indicator) { create(:indicator, model: model) }

    describe :promote_parent_to_system_indicator do
      subject {
        create(
          :indicator, parent: team_indicator, model: other_model
        )
      }
      it 'should create 2 new indicators' do
        expect { subject }.to(change { Indicator.count }.by(2))
      end
      it 'should turn team indicator into variation' do
        subject
        expect(team_indicator.variation?).to be(true)
      end
      it 'should not link variation to old team indicator' do
        expect(subject.parent).not_to eq(team_indicator)
      end
      it 'should link both variations to new system indicator' do
        expect(subject.parent).to eq(team_indicator.parent)
      end
    end
    describe :promote_to_system_indicator do
      subject { team_indicator.promote_to_system_indicator }
      it 'should create a new system indicator' do
        expect { subject }.to(change { Indicator.count }.by(1))
      end
      it 'should turn the team indicator into a variation' do
        subject
        expect(team_indicator.variation?).to be(true)
      end
      it 'should mark new system indicator as auto generated' do
        subject
        expect(team_indicator.parent.auto_generated).to be(true)
      end
    end
  end

  describe :destroy do
    let(:indicator) { create(:indicator) }
    let!(:variation) {
      create(
        :indicator, parent: indicator, model: create(:model)
      )
    }
    let!(:time_series_value) {
      create(:time_series_value, indicator: indicator)
    }
    it 'should destroy all time series values' do
      expect { indicator.destroy }.to change(TimeSeriesValue, :count).by(-1)
    end
    it 'should nullify parent in variations' do
      indicator.destroy
      expect(variation.reload.parent).to be_nil
    end
  end

  describe :slug_to_hash do
    it 'parses a 3-part slug' do
      expect(
        Indicator.slug_to_hash('A|B|C')
      ).to eq(category: 'A', subcategory: 'B', name: 'C')
    end
    it 'parses a 3-part slug with blank subcategory' do
      expect(
        Indicator.slug_to_hash('A||B')
      ).to eq(category: 'A', subcategory: nil, name: 'B')
    end
    it 'parses a 2-part slug' do
      expect(
        Indicator.slug_to_hash('A|B')
      ).to eq(category: 'A', subcategory: 'B')
    end
    it 'parses a long slug' do
      expect(
        Indicator.slug_to_hash('A|B|C|D')
      ).to eq(category: 'A', subcategory: 'B', name: 'C|D')
    end
  end

  describe :time_series_data? do
    let!(:indicator) { create(:indicator) }
    it 'returns false when no time series data present' do
      expect(indicator.time_series_data?).to be(false)
    end
    it 'returns true when time series data present' do
      create(:time_series_value, indicator: indicator)
      expect(indicator.time_series_data?).to be(true)
    end
  end

  describe :scenarios do
    let(:indicator) { create(:indicator) }
    let(:scenario) { create(:scenario) }
    let!(:time_series_value1) {
      create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    let!(:time_series_value2) {
      create(
        :time_series_value, indicator: indicator, scenario: scenario
      )
    }
    it 'should not double count' do
      expect(indicator.scenarios.count).to eq(1)
    end
  end
end
