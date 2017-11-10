require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'after_sign_in_path_for' do
    context 'when authorised user' do
      let(:admin) { create(:user, admin: true) }
      it 'goes to admin root' do
        expect(
          controller.send(:after_sign_in_path_for, admin)
        ).to eq(admin_root_path)
      end
    end

    context 'when unauthorised user' do
      let(:user) { create(:user, admin: false) }
      it 'goes to root' do
        expect(
          controller.send(:after_sign_in_path_for, user)
        ).to eq(root_path)
      end
    end
  end
end
