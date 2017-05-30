require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  let(:model) { FactoryGirl.create(:model) }
  describe :attribute_input do
    context :models do
      let(:form) {
        ActionView::Helpers::FormBuilder.new(:model, model, self, {})
      }
      it 'returns a text input for platform_details' do
        expect(
          helper.attribute_input(model, form, :platform_detailed)
        ).to match('input .* type="text"')
      end
      it 'returns a multiple select input for platform' do
        expect(
          helper.attribute_input(model, form, :platform)
        ).to match('js-multiple-select')
      end
      it 'returns a single select input for maintainer_type' do
        expect(
          helper.attribute_input(model, form, :maintainer_type)
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
    it 'returns Platform for platform' do
      expect(
        helper.attribute_name(model, :platform)
      ).to eq('Platform')
    end
  end

  describe :attribute_definition do
    it 'returns Platform for platform' do
      expect(
        helper.attribute_definition(model, :platform)
      ).to eq('What platform is the model run on?')
    end
  end
end
