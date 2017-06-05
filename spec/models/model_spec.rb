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
  pending 'should be invalid when team not present (?)' do
    expect(
      FactoryGirl.build(:model, team: nil)
    ).to have(1).errors_on(:team)
  end
  it 'should be invalid when trying to reassign team' do
    model = FactoryGirl.create(:model)
    another_team = FactoryGirl.create(:team)
    model.team = another_team
    expect(model).to have(1).errors_on(:team)
  end

  describe :create do
    it 'ignores blank array values for multiple selection attributes' do
      attributes = FactoryGirl.attributes_for(:model).
        merge(programming_language: ['', 'Python', 'ruby', 'perl'])
      expect(Model.create(attributes).programming_language.length).to eq(3)
    end
    it 'ignores blank array values for single selection attributes' do
      attributes = FactoryGirl.attributes_for(:model).
        merge(time_horizon: ['', 'century'])
      expect(Model.create(attributes).time_horizon).to eq('century')
    end
  end

  describe :attribute_infos do
    it 'should be an array' do
      expect(Model.attribute_infos.size).to eq(Model::ALL_ATTRIBUTES.size)
    end
  end

  describe :key_for_name do
    it 'should be models.platform.name for platform' do
      expect(
        Model.key_for_name(:platform)
      ).to eq('models.platform.name')
    end
  end

  describe :key_for_definition do
    it 'should be models.platform.definition for platform' do
      expect(
        Model.key_for_definition(:platform)
      ).to eq('models.platform.definition')
    end
  end
end
