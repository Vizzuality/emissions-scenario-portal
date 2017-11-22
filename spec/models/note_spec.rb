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

    it "is invalid when unit_of_entry is equal to indicator's unit" do
      indicator = create(:indicator)
      expect(
        build(:note, unit_of_entry: indicator.unit, indicator: indicator)
      ).to have(1).errors_on(:unit_of_entry)
    end

    it "is invalid when conversion_factor is present but no unit_of_entry given" do
      expect(
        build(:note, unit_of_entry: nil, conversion_factor: 0.1)
      ).to have(1).errors_on(:conversion_factor)
    end

    it "is invalid when conversion_factor is blank but unit_of_entry given" do
      expect(
        build(:note, unit_of_entry: "units", conversion_factor: nil)
      ).to have(1).errors_on(:conversion_factor)
    end

    it "is invalid when conversion_factor is zero" do
      expect(
        build(:note, unit_of_entry: "units", conversion_factor: 0)
      ).to have(1).errors_on(:conversion_factor)
    end

    it "is invalid without unit_of_entry when no description given" do
      expect(
        build(:note, unit_of_entry: nil, description: nil)
      ).to have(1).errors_on(:unit_of_entry)
    end
  end
end
