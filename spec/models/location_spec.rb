require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'should be invalid when name not present' do
    expect(
      build(:location, name: nil)
    ).to have(1).errors_on(:name)
  end
end
