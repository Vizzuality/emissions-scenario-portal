class ChangeGeographicCoverageToArrayInModels < ActiveRecord::Migration[5.1]
  Model = Class.new(ActiveRecord::Base)

  def change
    add_column :models, :geographic_coverage_array, :text, array: true
    Model.find_each do |model|
      model.update!(geographic_coverage_array: Array.wrap(model.geographic_coverage))
    end
    remove_column :models, :geographic_coverage
    rename_column :models, :geographic_coverage_array, :geographic_coverage
  end
end
