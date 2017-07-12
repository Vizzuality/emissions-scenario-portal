require 'rails_helper'

RSpec.describe IndicatorsHelper, type: :helper do
  let(:team) { FactoryGirl.create(:team) }
  let(:model) { FactoryGirl.create(:model, team: team) }
  let(:other_model) { FactoryGirl.create(:model) }
  let(:system_indicator) { FactoryGirl.create(:indicator, category: 'A') }
  let!(:team_variation) {
    FactoryGirl.create(
      :indicator, alias: '1|2|3', parent: system_indicator, model: model
    )
  }
  let!(:team_indicator) {
    FactoryGirl.create(:indicator, category: 'B', model: model)
  }
  let!(:other_team_indicator) {
    FactoryGirl.create(:indicator, category: 'B', model: other_model)
  }

  describe :types_for_select do
    before(:each) do
      allow(helper).to receive(:current_user).and_return(user)
    end
    let(:system_match) { '<option value="system">.+' }
    let(:team_match) { '<option value="team-.+">.+' }
    let(:other_match) { '<option value="other-.+">.+' }
    context 'when admin' do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      it 'returns system indicators in first position' do
        expect(helper.types_for_select).to match(
          /#{system_match}\n(#{team_match}\n?){3}/
        )
      end
    end
    context 'when researcher' do
      let(:user) { FactoryGirl.create(:user, team: team) }
      it 'returns system indicators in first position' do
        expect(helper.types_for_select).to match(
          /#{system_match}\n#{team_match}\n#{other_match}/
        )
      end
    end
  end

  describe :categories_for_select do
    it 'returns categories without duplicates' do
      expect(
        helper.categories_for_select
      ).to eq(options_for_select(%w(A B)))
    end
  end
end
