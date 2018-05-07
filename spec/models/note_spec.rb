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

    it "is invalid when conversion_factor is zero" do
      expect(
        build(:note, unit_of_entry: "units", conversion_factor: 0)
      ).to have(1).errors_on(:conversion_factor)
    end

    it "is invalid without unit_of_entry when conversion_factor given" do
      expect(
        build(:note, unit_of_entry: nil, conversion_factor: 2)
      ).to have(1).errors_on(:unit_of_entry)
    end

    it "is valid without unit_of_entry when conversion_factor 1" do
      expect(
        build(:note, unit_of_entry: nil, conversion_factor: 1)
      ).to be_valid
    end

  end

  context "after_save callback" do
    let(:note) {
      create(:note, conversion_factor: 1.0)
    }

    let!(:time_series_value) {
      scenario = create(:scenario, model_id: note.model_id)
      create(:time_series_value, scenario_id: scenario.id,
             indicator_id: note.indicator_id, value: 1.0)
    }

    let!(:frozen_time_series_value) {
      create(:time_series_value, indicator_id: note.indicator_id, value: 1.0)
    }

    it "triggers after_save callback when note is saved" do
      expect(note).to receive(:convert_time_series_values)
      note.save
    end

    it "updates time_series_values when conversion_factor changes" do
      note.update_attributes(conversion_factor: 2.0)
      time_series_value.reload
      expect(time_series_value.value).to eq(2.0)
    end

    it "doesn't update time_series_values when conversion_factor not edited" do
      note.update_attributes(description: 'derp')
      time_series_value.reload
      expect(time_series_value.value).to eq(1.0)
    end

    it "doesn't update time_series_values when conversion_factor doesn't change" do
      note.update_attributes(conversion_factor: '1.0')
      time_series_value.reload
      expect(time_series_value.value).to eq(1.0)
    end

    it "doesn't update time_series_values when conversion_factor changes to nil" do
      note.update_attributes(conversion_factor: nil)
      time_series_value.reload
      expect(time_series_value.value).to eq(1.0)
    end
  end
end
