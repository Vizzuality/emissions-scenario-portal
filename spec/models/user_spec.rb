require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should be invalid when email not present' do
    expect(
      build(:user, email: nil)
    ).to have(1).errors_on(:email)
  end
  it 'should be invalid when email not unique' do
    create(:user, email: 'john@example.com')
    expect(
      build(:user, email: 'john@example.com')
    ).to have(1).errors_on(:email)
  end
  it 'should be invalid if team missing and not admin' do
    expect(
      build(:user, admin: false, team: nil)
    ).to have(1).errors_on(:team)
  end
  it 'should not be invalid if team missing and admin' do
    expect(
      build(:user, admin: true, team: nil)
    ).to have(0).errors_on(:team)
  end
  it 'should be invalid when trying to reassign team' do
    user = create(:user)
    another_team = create(:team)
    user.team = another_team
    expect(user).to have(1).errors_on(:team)
  end
end
