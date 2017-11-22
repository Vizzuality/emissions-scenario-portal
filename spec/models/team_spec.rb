require 'rails_helper'

RSpec.describe Team, type: :model do
  it 'should be invalid when name not present' do
    expect(
      build(:team, name: nil)
    ).to have(1).errors_on(:name)
  end
  it 'should be invalid when name not unique' do
    create(:team, name: 'A-Team')
    expect(
      build(:team, name: 'A-Team')
    ).to have(1).errors_on(:name)
  end
  it 'should be invalid when invalid image is selected' do
    team = build(:team, image: File.new("#{Rails.root}/spec/fixtures/invalid_image.jpg"))
    expect(team).to have(1).errors_on(:image)
  end
    it 'should be valid when valid image is selected' do
    team = build(:team, image: File.new("#{Rails.root}/spec/fixtures/valid_image.jpg"))
    expect(team).to have(0).errors_on(:image)
  end
  describe :members_list_for_display do
    let(:team) { create(:team) }
    it 'displays email if name blank' do
      create(:user, name: 'A', email: 'a@example.com', team: team)
      create(:user, name: '', email: 'b@example.com', team: team)
      expect(team.members_list_for_display).to eq('A, b@example.com')
    end
  end
end
