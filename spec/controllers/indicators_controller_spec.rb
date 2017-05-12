require 'rails_helper'

RSpec.describe IndicatorsController, type: :controller do
  let!(:indicator) { FactoryGirl.create(:indicator) }

  describe 'GET index' do
    it 'renders index' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
