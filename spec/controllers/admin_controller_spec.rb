require 'rails_helper'

RSpec.describe AdminController, type: :controller do
  context 'when authorised user' do
    login_admin

    it 'should be success' do
      get :home
      expect(response).to be_success
    end
  end

  context 'when unauthorised user' do
    login_user

    it 'should be forbidden' do
      get :home
      expect(response).to be_forbidden
    end
  end
end
