require 'rails_helper'

RSpec.describe Category, type: :model do
  context 'should be invalid' do
    it 'when name not present' do
      category = build(:category, name: nil)
      expect(category).to have(1).errors_on(:name)
    end

    it 'when stackable without parent category' do
      category = build(:category, parent_id: nil, stackable: true)
      expect(category).to have(1).errors_on(:stackable)
    end

    it 'when parent category is a subcategory' do
      grandparent_category = create(:category)
      parent_category = create(:category, parent: grandparent_category)
      category = build(:category, parent: parent_category)
      expect(category).to have(1).errors_on(:parent)
    end
  end

  context 'haveing_time_series_with' do
    it 'should return categories having time series with given conditions' do
      category1 = create(:category)
      subcategory = create(:category, parent: category1)
      indicator = create(:indicator, subcategory: subcategory)
      create(:time_series_value, indicator: indicator, value: 1)

      category2 = create(:category)
      subcategory = create(:category, parent: category2)
      indicator = create(:indicator, subcategory: subcategory)
      create(:time_series_value, indicator: indicator, value: 2)

      expect(Category.having_time_series_with(value: 1)).to eq([category1])
    end
  end
end
