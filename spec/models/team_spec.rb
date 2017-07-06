require 'rails_helper'

RSpec.describe Team, type: :model do
  it 'should be invalid when name not present' do
    expect(
      FactoryGirl.build(:team, name: nil)
    ).to have(1).errors_on(:name)
  end
  it 'should be invalid when name not unique' do
    FactoryGirl.create(:team, name: 'A-Team')
    expect(
      FactoryGirl.build(:team, name: 'A-Team')
    ).to have(1).errors_on(:name)
  end
  describe :members_list_for_display do
    let(:team) { FactoryGirl.create(:team) }
    it 'displays email if name blank' do
      FactoryGirl.create(:user, name: 'A', email: 'a@example.com', team: team)
      FactoryGirl.create(:user, name: '', email: 'b@example.com', team: team)
      expect(team.members_list_for_display).to eq('A, b@example.com')
    end
  end
end
