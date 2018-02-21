require 'rails_helper'

RSpec.describe NotesController, type: :controller do
  context 'when user' do
    login_user
    let(:user_team) { @user.team }
    let(:team_model) { create(:model, team: user_team) }
    let(:other_model) { create(:model) }
    let(:indicator) { create(:indicator) }

    describe 'GET edit' do
      it 'redirects when no access to the model' do
        get(
          :edit,
          params: {
            model_id: other_model.id,
            indicator_id: indicator.id
          }
        )
        expect(response).to be_redirect
      end

      it 'renders edit for note' do
        get(
          :edit,
          params: {
            model_id: team_model.id,
            indicator_id: indicator.id
          }
        )
        expect(response).to render_template(:edit)
      end
    end

    describe 'PUT update when note exists' do
      let!(:note) { create(:note, indicator: indicator, model: team_model) }

      it 'redirects when no access to the model' do
        put(
          :update,
          params: {
            model_id: other_model.id,
            indicator_id: indicator.id,
            note: {conversion_factor: 1.0}
          }
        )
        expect(response).to be_redirect
      end

      it 'renders edit when validation errors' do
        put(
          :update,
          params: {
            model_id: team_model.id,
            indicator_id: indicator.id,
            note: {conversion_factor: "invalid"}
          }
        )
        expect(response).to render_template(:edit)
      end

      it 'redirects and updates note when valid params' do
        put(
          :update,
          params: {
            model_id: team_model.id,
            indicator_id: indicator.id,
            note: {conversion_factor: 1.0}
          }
        )
        expect(response).to be_redirect
        expect(note.reload.conversion_factor).to eq(1.0)
      end
    end

    describe 'PUT update when note does not exists' do
      it 'redirects when no access to the model' do
        put(
          :update,
          params: {
            model_id: other_model.id,
            indicator_id: indicator.id,
            note: {conversion_factor: 1.0}
          }
        )
        expect(response).to be_redirect
      end

      it 'renders edit when validation errors' do
        put(
          :update,
          params: {
            model_id: team_model.id,
            indicator_id: indicator.id,
            note: {conversion_factor: "invalid"}
          }
        )
        expect(response).to render_template(:edit)
      end

      it 'redirects and updates note when valid params' do
        put(
          :update,
          params: {
            model_id: team_model.id,
            indicator_id: indicator.id,
            note: {unit_of_entry: ["GW"], conversion_factor: 1}
          }
        )

        expect(response).to be_redirect
        expect(Note.last.conversion_factor).to eq(1.0)
      end
    end
  end
end
