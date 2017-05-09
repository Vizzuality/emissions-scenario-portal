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
end
