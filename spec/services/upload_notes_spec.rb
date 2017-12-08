require 'rails_helper'

RSpec.describe UploadNotes, upload: :s3 do
  let(:user) { create(:user) }
  let(:csv_upload) do
    create(
      :csv_upload,
      user: user,
      service_type: 'UploadNotes',
      data: file
    )
  end
  let!(:user) { create(:user, admin: true) }
  let!(:model) do
    create(:model, full_name: "Annual Energy Outlook 2017")
  end
  let!(:electricity) { create(:category, name: "Electricity") }
  let!(:additions) do
    create(
      :category,
      name: "Capacity additions by technology",
      parent: electricity
    )
  end
  let!(:coal) do
    create(
      :indicator,
      category: electricity,
      subcategory: additions,
      name: "Coal w/o CCS"
    )
  end
  let!(:gas) do
    create(
      :indicator,
      category: electricity,
      subcategory: additions,
      name: "Gas w/o CCS"
    )
  end

  subject { UploadNotes.new(csv_upload).call }

  context 'when file correct' do
    let(:file) do
      fixture_file_upload('files/notes-correct.csv')
    end
    it 'should have saved all rows' do
      expect { subject }.to change { Note.count }.by(2)
    end
    it 'should have correct message' do
      subject
      expect(csv_upload.message).to eq("2 of 2 rows saved.")
    end
  end

  context 'when column is missing' do
    let(:file) do
      fixture_file_upload('files/notes-missing_column.csv')
    end
    it 'should have saved all rows' do
      expect { subject }.to change { Note.count }.by(0)
    end
    it 'should have correct message' do
      subject
      expect(csv_upload.message).to eq("0 of 2 rows saved.")
      puts csv_upload.errors_and_warnings.inspect
    end
  end
end
