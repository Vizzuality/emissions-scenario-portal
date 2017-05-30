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
        ).to match('select multiple="multiple"')
      end
    end
    context :scenarios do
      let(:scenario) { FactoryGirl.create(:scenario) }
      let(:form) {
        ActionView::Helpers::FormBuilder.new(:scenario, @model, self, {})
      }
      pending 'returns a date input field for release_date'
      it 'returns a select input for model_abbreviation' do
        expect(
          helper.attribute_input(scenario, form, :model_abbreviation)
        ).to match('select')
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
