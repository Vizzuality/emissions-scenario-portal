require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'should be invalid when name not present' do
    expect(
      FactoryGirl.build(:location, name: nil)
    ).to have(1).errors_on(:name)
  end

  describe :fetch_all do
    let!(:location1) {
      FactoryGirl.create(:location, name: 'Poland', iso_code: 'PL')
    }
    let!(:location2) {
      FactoryGirl.create(:location, name: 'Portugal', iso_code: 'PT')
    }
    context 'when using text search' do
      it 'searches by iso codeca' do
        expect(
          Location.fetch_all('search' => 'PL')
        ).to match_array([location1])
      end
      it 'searches by name' do
        expect(
          Location.fetch_all('search' => 'pol')
        ).to match_array([location1])
      end
    end
    context 'when sorting' do
      it 'orders by name' do
        expect(
          Location.fetch_all('order_type' => 'name')
        ).to eq([location1, location2])
      end
      it 'orders by iso code' do
        expect(
          Location.fetch_all('order_type' => 'iso_code')
        ).to eq([location1, location2])
      end
    end
  end
end
