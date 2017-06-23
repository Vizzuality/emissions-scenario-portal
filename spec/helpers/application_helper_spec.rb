require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:model) { FactoryGirl.create(:model) }
  describe :attribute_input do
    context :models do
      let(:form) {
        ActionView::Helpers::FormBuilder.new(:model, model, self, {})
      }
      it 'returns a text input for expertise_detailed' do
        expect(
          helper.attribute_input(model, form, :expertise_detailed)
        ).to match('input .* type="text"')
      end
      it 'returns a multiple select input for anticipation' do
        expect(
          helper.attribute_input(model, form, :anticipation)
        ).to match('js-multiple-select')
      end
      it 'returns a single select input for geographic_coverage' do
        expect(
          helper.attribute_input(model, form, :geographic_coverage)
        ).to match('js-multisingle-select')
      end
    end
    context :scenarios do
      let(:scenario) { FactoryGirl.create(:scenario) }
      let(:form) {
        ActionView::Helpers::FormBuilder.new(:scenario, scenario, self, {})
      }
      it 'returns a date input field for release_date' do
        expect(
          helper.attribute_input(scenario, form, :release_date)
        ).to match('js-datepicker-input')
      end
      it 'returns a select input for model_abbreviation' do
        expect(
          helper.attribute_input(scenario, form, :model_abbreviation)
        ).to match('select')
      end
    end
    context :indicators do
      let(:indicator) { FactoryGirl.create(:indicator) }
      let(:form) {
        ActionView::Helpers::FormBuilder.new(:indicator, indicator, self, {})
      }
      it 'returns a checkbox for release_date' do
        expect(
          helper.attribute_input(indicator, form, :stackable_subcategory)
        ).to match('checkbox')
      end
    end
  end

  describe :attribute_name do
    it 'returns Expertise for expertise' do
      expect(
        helper.attribute_name(model, :expertise)
      ).to eq('Expertise')
    end
  end

  describe :attribute_definition do
    it 'returns Platform for expertise' do
      expect(
        helper.attribute_definition(model, :expertise)
      ).to eq('What is the skill level required to run the model?')
    end
  end
end
