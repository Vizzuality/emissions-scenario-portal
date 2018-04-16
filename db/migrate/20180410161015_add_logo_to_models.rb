class AddLogoToModels < ActiveRecord::Migration[5.1]
  def change
    add_column :models, :logo_file_name, :string
    add_column :models, :logo_content_type, :string
    add_column :models, :logo_file_size, :integer
    add_column :models, :logo_updated_at, :datetime
  end
end
