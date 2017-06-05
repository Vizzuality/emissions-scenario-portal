require 'rails_helper'

RSpec.describe UploadIndicators do
  let(:user) { FactoryGirl.create(:user) }
  let(:model) {
    FactoryGirl.create(:model, abbreviation: 'Model A', team: user.team)
  }

  subject { UploadIndicators.new(user, model).call(file) }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-correct.csv'
        )
      )
    }
    it 'should have saved all rows' do
      expect { subject }.to change { Indicator.count }.by(3)
    end
    it 'should report all rows saved' do
      # 1 row with 2 values, 1 row with 1 value
      expect(subject.number_of_rows_saved).to eq(2)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_rows_failed).to eq(0)
    end
  end

  context 'when file correct and overwrites old data' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-correct.csv'
        )
      )
    }
    before(:each) do
      FactoryGirl.create(
        :indicator,
        category: 'Emissions',
        subcategory: 'CO2 by sector',
        name: 'industry',
        model: nil,
        parent: nil
      )
    end
    it 'should not have saved new rows' do
      expect { subject }.to change { Indicator.count }.by(2)
    end
    it 'should report all rows saved' do
      # 1 row with 2 values, 1 row with 1 value
      expect(subject.number_of_rows_saved).to eq(2)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_rows_failed).to eq(0)
    end
  end

  context 'when file with invalid column name' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-invalid_column.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Indicator.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(1)
    end
  end
end
