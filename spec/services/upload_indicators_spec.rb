require 'rails_helper'

RSpec.describe UploadIndicators, upload: :s3 do
  let(:user) { create(:user, admin: true) }
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
        file_fixture('indicators-correct.csv')
      )
    }
    it 'should have saved all indicators' do
      expect { subject }.to change { Indicator.count }.by(2)
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
        file_fixture('indicators-correct.csv')
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
        subcategory: subcategory,
        name: 'industry',
        unit: 'Mt CO2e/yr'
      )
    end

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

  context 'when not stackable subcategory' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        file_fixture('indicators-not_stackable_subcategory.csv')
      )
    }

    it 'should have saved new rows' do
      expect { subject }.to change { Indicator.count }.by(2)
    end
    it 'should have created one indicator with not stackable subcategory' do
      expect { subject }.to change {
        Indicator.
          includes(:subcategory).
          references(:subcategory).
          where(categories: {stackable: false}).count
      }.by(1)
    end
    it 'should have created one indicator with stackable subcategory' do
      expect { subject }.to change {
        Indicator.
          includes(:subcategory).
          references(:subcategory).
          where(categories: {stackable: true}).count
      }.by(1)
    end
  end

  context 'when file with invalid column name' do
    let(:file) {
      Rack::Test::UploadedFile.new(
        file_fixture('indicators-invalid_column.csv')
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
        file_fixture('indicators-missing_name.csv')
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
end
