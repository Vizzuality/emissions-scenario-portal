require 'rails_helper'

RSpec.describe CategoriesController, type: :controller do
  let(:some_categories) {
    create_list(:category, 10)
  }

  context 'when admin' do
    login_admin

    describe 'GET index' do
      it 'renders index' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    describe 'GET new' do
      it 'renders new' do
        get :new
        expect(response).to render_template(:edit)
      end
    end

    describe 'GET edit' do
      it 'renders edit' do
        get :edit, params: {id: some_categories[0].id}
        expect(response).to render_template(:edit)
      end
    end

    describe 'POST create' do
      it 'redirects to category when successful' do
        post :create, params: {
          category: {name: 'Edited Name'}
        }
        expect(response).to redirect_to(edit_category_url(assigns(:category)))
      end

      it 'renders edit when validation errors present' do
        post :create, params: {
          category: {name: nil}
        }
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update' do
      it 'redirects to category when successful' do
        put :update, params: {
          id: some_categories[0].id,
          category: {name: 'Edited Name'}
        }
        expect(response).to redirect_to(edit_category_url(assigns(:category)))
      end

      it 'renders edit when validation errors present' do
        put :update, params: {
          id: some_categories[0].id,
          category: {name: nil}
        }
        expect(response).to render_template(:edit)
      end
    end
  end
end
