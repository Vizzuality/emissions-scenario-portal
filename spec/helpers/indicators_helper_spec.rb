require 'rails_helper'

RSpec.describe IndicatorsHelper, type: :helper do
  let(:team) { create(:team) }
  let(:model) { create(:model, team: team) }
  let(:other_model) { create(:model) }
3
  describe :categories_for_select do
    let!(:top_level_category) {
      create(:category, parent: nil, name: 'Buildings')
    }
    let!(:another_category) {
      create(:category, parent: top_level_category, name: 'Transportation')
    }

    it 'returns categories without duplicates' do
      expect(
        helper.categories_for_select
      ).to eq(
        options_for_select(
          [
            [top_level_category.name, top_level_category.id]
          ]
        )
      )
    end
  end
end
