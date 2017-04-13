require 'rails_helper'

RSpec.describe User, type: :model do
  it "should be invalid when email not present" do
    expect(
      FactoryGirl.build(:user, email: nil)
    ).to have(1).errors_on(:email)
  end
  it "should be invalid when email not unique" do
    FactoryGirl.create(:user, email: 'john@example.com')
    expect(
      FactoryGirl.build(:user, email: 'john@example.com')
    ).to have(1).errors_on(:email)
  end
  it "should be invalid if team missing and not admin" do
    expect(
      FactoryGirl.build(:user, admin: false, team: nil)
    ).to have(1).errors_on(:team)
  end
  it "should not be invalid if team missing and admin" do
    expect(
      FactoryGirl.build(:user, admin: true, team: nil)
    ).to have(0).errors_on(:team)
  end
end
