require 'rails_helper'

RSpec.describe Note, type: :model do
  context 'validations' do
    it 'has a valid factory' do
      expect(
        create(:note)
      ).to be_persisted
    end

    it 'is invalid without model' do
      expect(
        build(:note, model: nil)
      ).to have(1).errors_on(:model)
    end

    it 'is invalid without indicator' do
      expect(
        build(:note, indicator: nil)
      ).to have(1).errors_on(:indicator)
    end

    it 'is invalid when another note for indicator and model exists' do
      note = create(:note)
      expect(
        build(:note, model: note.model, indicator: note.indicator)
      ).to have(1).errors_on(:indicator_id)
    end
  end
end
