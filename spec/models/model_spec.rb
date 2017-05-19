require 'rails_helper'

RSpec.describe Model, type: :model do
  it 'should be invalid when abbreviation not present' do
    expect(
      FactoryGirl.build(:model, abbreviation: nil)
    ).to have(1).errors_on(:abbreviation)
  end
  it 'should be invalid when abbreviation not unique' do
    FactoryGirl.create(:model, abbreviation: 'A-Team')
    expect(
      FactoryGirl.build(:model, abbreviation: 'A-Team')
    ).to have(1).errors_on(:abbreviation)
  end
  it 'should be invalid when team not present' do
    expect(
      FactoryGirl.build(:model, team: nil)
    ).to have(1).errors_on(:team)
  end

  describe :create do
    it 'ignores blank array values' do
      attributes = FactoryGirl.attributes_for(:model).
        merge(programming_language: ['', 'Python', 'ruby', 'perl'])
      expect(Model.create(attributes).programming_language.length).to eq(3)
    end
  end

  describe :attribute_symbols do
    it 'should be an array' do
      expect(Model.attribute_symbols.size).to eq(Model::ALL_ATTRIBUTES.size)
    end
  end

  describe :picklist_attribute? do
    it 'platform should be a picklist attribute' do
      expect(Model.picklist_attribute?(:platform)).to be(true)
    end
    it 'platform_detailed should not be a picklist attribute' do
      expect(Model.picklist_attribute?(:platform_detailed)).to be(false)
    end
  end

  describe :multiple_attribute? do
    it 'platform should be a picklist attribute' do
      expect(Model.multiple_attribute?(:platform)).to be(true)
    end
    it 'platform_detailed should not be a picklist attribute' do
      expect(Model.multiple_attribute?(:platform_detailed)).to be(false)
    end
  end

  describe :size_attribute do
    it 'platform should have large size' do
      expect(Model.size_attribute(:platform)).to eq('large')
    end
  end

  describe :category_attribute do
    it 'platform should be in General Info category' do
      expect(Model.category_attribute(:platform)).to eq('Details & Description')
    end
  end

  describe :key_for_name do
    let(:model) { FactoryGirl.create(:model) }
    it 'should be models.platform.name for platform' do
      expect(
        model.key_for_name(:platform)
      ).to eq('models.platform.name')
    end
  end

  describe :key_for_definition do
    let(:model) { FactoryGirl.create(:model) }
    it 'should be models.platform.definition for platform' do
      expect(
        model.key_for_definition(:platform)
      ).to eq('models.platform.definition')
    end
  end
end
