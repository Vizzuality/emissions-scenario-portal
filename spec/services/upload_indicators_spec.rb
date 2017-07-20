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
    context 'when admin' do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      it 'should have saved all indicators' do
        expect { subject }.to change { Indicator.count }.by(3)
      end
      it 'should report all rows saved' do
        expect(subject.number_of_records_saved).to eq(2)
      end
      it 'should report no rows failed' do
        expect(subject.number_of_records_failed).to eq(0)
      end
    end
    context 'when researcher' do
      it 'should have saved all non-system indicators' do
        expect { subject }.to change { Indicator.count }.by(2)
      end
      it 'should report non-system indicators rows saved' do
        expect(subject.number_of_records_saved).to eq(1)
      end
      it 'should report system indicator rows failed' do
        expect(subject.number_of_records_failed).to eq(1)
      end
    end
    context 'when researcher from another team' do
      let(:user) { FactoryGirl.create(:user) }
      let(:model) {
        FactoryGirl.create(:model, abbreviation: 'Model A')
      }
      it 'should not have saved any indicators' do
        expect { subject }.to change { Indicator.count }.by(0)
      end
      it 'should report no rows saved' do
        expect(subject.number_of_records_saved).to eq(0)
      end
      it 'should report all rows failed' do
        expect(subject.number_of_records_failed).to eq(2)
      end
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
        unit: 'Mt CO2e/yr',
        model: nil,
        parent: nil
      )
    end
    context 'when admin' do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      it 'should have saved new rows' do
        expect { subject }.to change { Indicator.count }.by(2)
      end
      it 'should report all rows saved' do
        expect(subject.number_of_records_saved).to eq(2)
      end
      it 'should report no rows failed' do
        expect(subject.number_of_records_failed).to eq(0)
      end
    end
    context 'when researcher' do
      it 'should have saved new rows' do
        expect { subject }.to change { Indicator.count }.by(1)
      end
      it 'should report all rows saved' do
        expect(subject.number_of_records_saved).to eq(1)
      end
      it 'should report no rows failed' do
        expect(subject.number_of_records_failed).to eq(1)
      end
    end
  end

  context 'when 2 team indicators based on same absent system indicator' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-two_team_indicators.csv'
        )
      )
    }
    context 'when admin' do
      let(:user) { FactoryGirl.create(:user, admin: true) }
      it 'should have saved new rows' do
        expect { subject }.to change { Indicator.count }.by(3)
      end
      it 'should have created a system indicator' do
        expect { subject }.to change {
          Indicator.where(parent_id: nil).count
        }.by(1)
      end
      it 'should have created 2 variations' do
        subject
        system_indicator = Indicator.where(parent_id: nil).first
        expect(system_indicator.variations.count).to eq(2)
      end
      it 'should report all rows saved' do
        expect(subject.number_of_records_saved).to eq(2)
      end
      it 'should report no rows failed' do
        expect(subject.number_of_records_failed).to eq(0)
      end
    end
    context 'when researcher' do
      it 'should have saved new rows' do
        expect { subject }.to change { Indicator.count }.by(3)
      end
      it 'should have created a team indicator' do
        expect { subject }.to change {
          Indicator.where(parent_id: nil).where('model_id IS NOT NULL').count
        }.by(1)
      end
      it 'should have created 2 variations' do
        subject
        system_indicator = Indicator.where(parent_id: nil).first
        expect(system_indicator.variations.count).to eq(2)
      end
      it 'should report all rows saved' do
        expect(subject.number_of_records_saved).to eq(2)
      end
      it 'should report no rows failed' do
        expect(subject.number_of_records_failed).to eq(0)
      end
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
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when missing name' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-missing_name.csv'
        )
      )
    }

    it 'should not have saved any rows' do
      expect { subject }.not_to(change { Indicator.count })
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(0)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
    end
  end

  context 'when incompatible unit' do
    let(:user) { FactoryGirl.create(:user, admin: true) }
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-incompatible_unit.csv'
        )
      )
    }

    before(:each) do
      system_indicator = FactoryGirl.create(
        :indicator,
        category: 'Emissions',
        subcategory: 'CO2 by sector',
        name: 'transport',
        unit: 'Mt CO2e/yr',
        model: nil,
        parent: nil
      )
      FactoryGirl.create(
        :indicator,
        category: 'Emissions',
        subcategory: 'CO2',
        name: 'Fossil Fuels and Industry|Energy Demand|Transport',
        unit: 'Mt CO2e/yr',
        model: model,
        parent: system_indicator,
        alias: 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Transport'
      )
    end

    it 'should not have saved any rows' do
      expect { subject }.to(change { Indicator.count }.by(2))
    end
    it 'should report no rows saved' do
      expect(subject.number_of_records_saved).to eq(1)
    end
    it 'should report all rows failed' do
      expect(subject.number_of_records_failed).to eq(2)
    end
  end
end
