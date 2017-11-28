require 'rails_helper'

RSpec.describe IndicatorsHelper, type: :helper do
  let(:team) { create(:team) }
  let(:model) { create(:model, team: team) }
  let(:other_model) { create(:model) }
  let(:category) {
    create(:category, name: 'Buildings')
  }
  let(:another_category) {
    create(:category, name: 'Transportation')
  }
  let!(:indicator) {
    create(:indicator, category: category, subcategory: nil)
  }

  describe :categories_for_select do
    it 'returns categories without duplicates' do
      expect(
        helper.categories_for_select
      ).to eq(
        options_for_select(
          [
            [category.name, category.id],
            [another_category.name, another_category.id]
          ]
        )
      )
    end
  end
end
