require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  context 'when admin' do
    login_admin
    let!(:location) { create(:location) }

    describe 'GET index' do
      it 'renders index template successfully' do
        get :index
        expect(response).to render_template(:index)
      end
    end
  end
end
