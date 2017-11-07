require 'rails_helper'

RSpec.describe IndicatorsHelper, type: :helper do
  let(:team) { create(:team) }
  let(:model) { create(:model, team: team) }
  let(:other_model) { create(:model) }
  let(:system_indicator) {
    create(:indicator, category: 'Buildings')
  }
  let!(:team_variation) {
    create(
      :indicator, alias: '1|2|3', parent: system_indicator, model: model
    )
  }
  let!(:team_indicator) {
    create(:indicator, category: 'Transportation', model: model)
  }
  let!(:other_team_indicator) {
    create(
      :indicator, category: 'Transportation', model: other_model
    )
  }

  describe :types_for_select do
    before(:each) do
      allow(helper).to receive(:current_user).and_return(user)
    end
    let(:system_match) { '<option value="system">.+' }
    let(:team_match) { '<option value="team-.+">.+' }
    context 'when admin' do
      let(:user) { create(:user, admin: true, team: team) }
      it 'returns system indicators in first position' do
        expect(helper.types_for_select).to match(
          /#{system_match}\n(#{team_match}\n?){2}/
        )
      end
    end
    context 'when researcher' do
      let(:user) { create(:user, team: team) }
      it 'returns system indicators in first position' do
        expect(helper.types_for_select).to match(
          /#{system_match}\n(#{team_match}\n?){2}/
        )
      end
    end
  end

  describe :categories_for_select do
    it 'returns categories without duplicates' do
      expect(
        helper.categories_for_select
      ).to eq(options_for_select(%w(Buildings Transportation)))
    end
  end
end
