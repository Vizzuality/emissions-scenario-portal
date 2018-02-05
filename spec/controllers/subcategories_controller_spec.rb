require 'rails_helper'

RSpec.describe SubcategoriesController, type: :controller do
  context 'when admin' do
    login_admin

    describe 'POST create' do
      let(:parent) { create(:category) }

      it 'redirects to category when successful' do
        post(
          :create,
          params: {
            category_id: parent.id,
            category: {name: 'New Subcategory'}
          }
        )
        expect(response).to redirect_to(edit_category_url(parent.id))
      end

      it 'contains flash alert when validation fails' do
        post(
          :create,
          params: {
            category_id: parent.id,
            category: {name: nil}
          }
        )
        expect(flash[:alert]).to be_present
      end
    end

    describe 'DELETE destroy' do
      let(:parent) { create(:category) }
      let(:subcategory) { create(:category, parent: parent) }

      it 'redirects to category when successful' do
        delete(
          :destroy,
          params: {
            category_id: parent.id,
            id: subcategory.id
          }
        )
        expect(response).to redirect_to(edit_category_url(parent.id))
      end

      it 'renders edit when validation errors present' do
        create(:indicator, subcategory: subcategory)

        delete(
          :destroy,
          params: {
            category_id: parent.id,
            id: subcategory.id
          }
        )
        expect(flash[:alert]).to be_present
      end
    end
  end
end
