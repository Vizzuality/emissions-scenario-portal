require 'rails_helper'

RSpec.describe Model, type: :model do
  it 'should be invalid when abbreviation not present' do
    expect(
      FactoryGirl.build(:model, abbreviation: nil)
    ).to have(1).errors_on(:abbreviation)
  end
  it 'should be invalid when abbreviation not unique' do
    FactoryGirl.create(:model, abbreviation: 'A-Team')
    expect(
      FactoryGirl.build(:model, abbreviation: 'A-Team')
    ).to have(1).errors_on(:abbreviation)
  end
  it 'should be inmvalid when team not present' do
    expect(
      FactoryGirl.build(:model, team: nil)
    ).to have(1).errors_on(:team)
  end
end
