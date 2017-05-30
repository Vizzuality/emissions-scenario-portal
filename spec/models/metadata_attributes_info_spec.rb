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
end