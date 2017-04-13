require 'rails_helper'

RSpec.describe Model, type: :model do
  it "should be invalid when name not present" do
    expect(
      FactoryGirl.build(:model, name: nil)
    ).to have(1).errors_on(:name)
  end
  it "should be invalid when name not unique" do
    FactoryGirl.create(:model, name: 'A-Team')
    expect(
      FactoryGirl.build(:model, name: 'A-Team')
    ).to have(1).errors_on(:name)
  end
  it "should be inmvalid when team not present" do
    expect(
      FactoryGirl.build(:model, team: nil)
    ).to have(1).errors_on(:team)   
  end
end
