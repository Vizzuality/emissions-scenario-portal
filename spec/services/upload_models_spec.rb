require 'rails_helper'

RSpec.describe UploadModels do
  let(:user) { FactoryGirl.create(:user) }
  let!(:model) {
    FactoryGirl.create(:model, team: user.team)
  }

  subject { UploadModels.new(user, model).call(file) }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'models-correct.csv'
        )
      )
    }
    it 'should have saved all rows' do
      expect { subject }.to change { Model.count }.by(2)
    end
    it 'should report all rows saved' do
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
          'models-correct.csv'
        )
      )
    }
    before(:each) do
      FactoryGirl.create(
        :model, abbreviation: 'Model A', team: user.team
      )
    end
    it 'should only have saved new rows' do
      expect { subject }.to change { Model.count }.by(1)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_rows_saved).to eq(2)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_rows_failed).to eq(0)
    end
  end

  context 'when file with invalid column' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'models-invalid_column.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Model.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(2)
    end
  end

  context 'when missing abreviation' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'models-missing_abbreviation.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Model.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(1)
    end
  end

  context 'when user without permissions tries to update a row' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'models-correct.csv'
        )
      )
    }
    before(:each) do
      FactoryGirl.create(
        :model, abbreviation: 'Model A'
      )
      FactoryGirl.create(
        :model, abbreviation: 'Model B'
      )
    end
    subject {
      UploadModels.new(user, model).call(file)
    }
    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Model.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_rows_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_rows_failed).to eq(2)
    end
  end
end
