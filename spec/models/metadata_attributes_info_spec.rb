require 'rails_helper'

RSpec.describe MetadataAttributes::Info, type: :model do
  describe :reference? do
    let(:reference_attribute_info) {
      Scenario.attribute_info(:model_abbreviation)
    }
    let(:not_reference_attribute_info) {
      Scenario.attribute_info(:description)
    }
    it 'should be true when attribute is a reference' do
      expect(reference_attribute_info.reference?).to be(true)
    end
    it 'should be false when attribute is not a reference' do
      expect(not_reference_attribute_info.reference?).to be(false)
    end
  end

  describe :date? do
    let(:date_attribute_info) {
      Scenario.attribute_info(:release_date)
    }
    let(:not_date_attribute_info) {
      Scenario.attribute_info(:description)
    }
    it 'should be true when attribute is a date' do
      expect(date_attribute_info.date?).to be(true)
    end
    it 'should be false when attribute is not a date' do
      expect(not_date_attribute_info.date?).to be(false)
    end
  end

  describe :picklist? do
    let(:picklist_attribute_info) {
      Model.attribute_info(:platform)
    }
    let(:not_picklist_attribute_info) {
      Model.attribute_info(:platform_detailed)
    }
    it 'should be true when attribute is a picklist' do
      expect(picklist_attribute_info.picklist?).to be(true)
    end
    it 'should be false when attribute is not a picklist' do
      expect(not_picklist_attribute_info.picklist?).to be(false)
    end
  end

  describe :multiple? do
    let(:multiple_attribute_info) {
      Model.attribute_info(:platform)
    }
    let(:not_multiple_attribute_info) {
      Model.attribute_info(:platform_detailed)
    }
    it 'should be true when attribute is multiple selection' do
      expect(multiple_attribute_info.multiple?).to be(true)
    end
    it 'should be false when attribute is not multiple selection' do
      expect(not_multiple_attribute_info.multiple?).to be(false)
    end
  end

  describe :size do
    it 'platform should have large size' do
      expect(Model.attribute_info(:platform).size).to eq('large')
    end
  end

end