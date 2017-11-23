require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'should be invalid when name blank' do
    expect(
      build(:location, name: nil)
    ).to have(1).errors_on(:name)
  end

  it 'should be invalid when region blank' do
    expect(
      build(:location, region: nil)
    ).to have(1).errors_on(:region)
  end

  it 'should be invalid when iso_code blank and not region' do
    expect(
      build(:location, region: false, iso_code: nil)
    ).to have(1).errors_on(:iso_code)
  end

  it 'should be invalid when name already exists' do
    create(:location, name: "Africa")
    expect(
      build(:location, name: "Africa")
    ).to have(1).errors_on(:name)
  end

  it 'should be invalid when iso_code already exists' do
    create(:location, iso_code: "AF")
    expect(
      build(:location, iso_code: "AF")
    ).to have(1).errors_on(:iso_code)
  end

  it 'should be invalid when invalid iso_code' do
    expect(
      build(:location, iso_code: "A")
    ).to have(1).errors_on(:iso_code)
  end
end
