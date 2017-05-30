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
end