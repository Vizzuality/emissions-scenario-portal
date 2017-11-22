require 'rails_helper'

RSpec.describe FilterTeams do
  let!(:team1) do
    create(:team, name: 'Team1')
  end
  let!(:team2) do
    create(:team, name: 'Team2')
  end

  context 'when using search' do
    it 'searches by name' do
      expect(
        FilterTeams.new(search: 'team1').call(Team.all)
      ).to match_array([team1])
    end
  end

  context 'when sorting' do
    it 'orders by name' do
      expect(
        FilterTeams.new(order_type: 'name').call(Team.all)
      ).to eq([team1, team2])
    end

    it 'orders by members' do
      create_list(:user, 3, team: team1)
      create_list(:user, 1, team: team2)

      expect(
        FilterTeams.new(order_type: 'members').call(Team.all)
      ).to eq([team2, team1])
    end

    it 'orders by models' do
      create_list(:model, 3, team: team1)
      create_list(:model, 1, team: team2)

      expect(
        FilterTeams.new(order_type: 'models').call(Team.all)
      ).to eq([team2, team1])
    end
  end
end
