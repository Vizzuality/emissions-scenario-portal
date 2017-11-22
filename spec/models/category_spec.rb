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
end
