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
      pending 'returns a date input field for release_date'
    end
  end

  describe :attribute_category do
    it 'returns Details & Description for platform' do
      expect(
        helper.attribute_category(model, :platform)
      ).to eq('Details & Description')
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
