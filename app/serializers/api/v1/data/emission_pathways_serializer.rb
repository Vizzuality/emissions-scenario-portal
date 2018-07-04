module Api
  module V1
    module Data
      class EmissionPathwaysSerializer < ActiveModel::Serializer
        attribute :id
        attribute(:location) { object['location'] }
        attribute(:iso_code2) { object['iso_code2'] }
        attribute(:model) { object['model'] }
        attribute(:scenario) { object['scenario'] }
        attribute(:category) { object['category'] }
        attribute(:subcategory) { object['subcategory'] }
        attribute(:indicator) { object['indicator'] }
        attribute(:unit) { object['unit'] }
        attribute(:definition) { object['definition'] }
        attribute(:emissions) { object['emissions'] }
      end
    end
  end
end
