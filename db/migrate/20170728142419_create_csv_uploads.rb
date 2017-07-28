class CreateCsvUploads < ActiveRecord::Migration[5.0]
  def change
    create_table :csv_uploads do |t|
      t.text :job_id
      t.references :user, foreign_key: {on_delete: :cascade}, null: false
      t.references :model, foreign_key: {on_delete: :cascade}
      t.text :service_type, null: false
      t.datetime :finished_at
      t.boolean :success
      t.text :message
      t.jsonb :errors_and_warnings

      t.timestamps
    end
  end
end
