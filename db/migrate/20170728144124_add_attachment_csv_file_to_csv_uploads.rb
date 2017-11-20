class AddAttachmentCsvFileToCsvUploads < ActiveRecord::Migration[5.1]
  def self.up
    change_table :csv_uploads do |t|
      t.attachment :data
    end
  end

  def self.down
    remove_attachment :csv_uploads, :data
  end
end
