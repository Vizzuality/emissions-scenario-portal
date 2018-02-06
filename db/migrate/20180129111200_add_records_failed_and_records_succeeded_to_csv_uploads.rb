class AddRecordsFailedAndRecordsSucceededToCsvUploads < ActiveRecord::Migration[5.1]
  def change
    add_column :csv_uploads, :number_of_records_saved, :integer, default: 0
  end
end
