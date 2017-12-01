require 'rails_helper'

RSpec.describe UploadIndicators, upload: :s3 do
  let(:user) { create(:user) }
  let(:csv_upload) {
    create(
      :csv_upload,
      user: user,
      service_type: 'UploadIndicators',
      data: file
    )
  }

  subject { UploadIndicators.new(csv_upload).call }

  context 'when file correct' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'indicators-correct.csv')
      )
    }
    let(:user) { create(:user, admin: true) }
    it 'should have saved all indicators' do
      expect { subject }.to change { Indicator.count }.by(3)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(2)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
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
      category = create(:category, name: 'Emissions')
      subcategory = create(
        :category,
        name: 'CO2 by sector',
        parent: category,
        stackable: true
      )
      create(
        :indicator,
        category: category,
        subcategory: subcategory,
        name: 'industry',
        unit: 'Mt CO2e/yr'
      )
    end

    let(:user) { create(:user, admin: true) }
    it 'should have saved new rows' do
      expect { subject }.to change { Indicator.count }.by(2)
    end
    it 'should report all rows saved' do
      expect(subject.number_of_records_saved).to eq(2)
    end
    it 'should report no rows failed' do
      expect(subject.number_of_records_failed).to eq(1)
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
    let(:user) { create(:user, admin: true) }
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

  context 'when not stackable subcategory' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        File.join(
          Rails.root,
          'spec',
          'fixtures',
          'indicators-not_stackable_subcategory.csv'
        )
      )
    }

    it 'should have saved new rows' do
      expect { subject }.to change { Indicator.count }.by(4)
    end
    it 'should have created one indicator with not stackable subcategory' do
      expect { subject }.to change {
        Indicator.
          includes(:subcategory).
          references(:subcategory).
          where(categories: {stackable: false}).count
      }.by(2)
    end
    it 'should have created one indicator with stackable subcategory' do
      expect { subject }.to change {
        Indicator.
          includes(:subcategory).
          references(:subcategory).
          where(categories: {stackable: true}).count
      }.by(2)
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
    let(:user) { create(:user, admin: true) }
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
      category = create(:category, name: 'Emissions')
      subcategory1 = create(:category, name: 'CO2 by sector', parent: category)
      subcategory2 = create(:category, name: 'CO2', parent: category)

      system_indicator = create(
        :indicator,
        category: category,
        subcategory: subcategory1,
        name: 'transport',
        unit: 'Mt CO2e/yr'
      )
      create(
        :indicator,
        category: category,
        subcategory: subcategory2,
        name: 'Fossil Fuels and Industry|Energy Demand|Transport',
        unit: 'Mt CO2e/yr',
        composite_name: 'Emissions|CO2|Fossil Fuels and Industry|Energy Demand|Transport'
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
