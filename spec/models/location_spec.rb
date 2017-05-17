require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'should be invalid when name not present' do
    expect(
      FactoryGirl.build(:location, name: nil)
    ).to have(1).errors_on(:name)
  end

  it 'should be invalid when iso code not present and not region' do
    expect(
      FactoryGirl.build(:location, iso_code2: nil, region: false)
    ).to have(1).errors_on(:iso_code2)
  end
end
