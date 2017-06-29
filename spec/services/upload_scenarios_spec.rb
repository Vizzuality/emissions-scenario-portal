require 'rails_helper'

RSpec.describe UploadScenarios do
  let(:user) { FactoryGirl.create(:user) }
  let(:model) {
    FactoryGirl.create(:model, abbreviation: 'Model A', team: user.team)
  }

  subject { UploadScenarios.new(user, model).call(file) }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-correct.csv'
        )
      )
    }
    it 'should have saved all rows' do
      expect { subject }.to change { Scenario.count }.by(1)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when file correct and overwrites old data' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-correct.csv'
        )
      )
    }
    before(:each) do
      FactoryGirl.create(
        :scenario,
        model: model,
        name: 'Scenario 1'
      )
    end
    it 'should only have saved new rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(0)
    end
  end

  context 'when file with invalid column' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-invalid_column.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when file with unrecognised model' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-unrecognised_model.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(2)
    end
  end

  context 'when missing name' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-missing_name.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when invalid property' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-invalid_property.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when user without permissions' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'scenarios-correct.csv'
        )
      )
    }
    subject {
      UploadScenarios.new(FactoryGirl.create(:user), model).call(file)
    }
    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Scenario.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end
end
