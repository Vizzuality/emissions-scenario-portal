require 'active_support/concern'

module ModelAttributes
  extend ActiveSupport::Concern

  included do
    validates :abbreviation, presence: true, uniqueness: true
    validates :full_name, presence: true
    validates :development_year,
      numericality: {only_integer: true, allow_nil: true},
      inclusion: {in: 1900..Date.today.year, allow_nil: true}
    validates :base_year,
      numericality: {only_integer: true, allow_nil: true},
      inclusion: {in: 1900..Date.today.year, allow_nil: true}
    validates_format_of :url, :with => URI::regexp(%w(http https)),
      allow_blank: true
  end

  def key_for_name(attribute_symbol)
    ['models', attribute_symbol, 'name'].join('.')
  end

  def key_for_definition(attribute_symbol)
    ['models', attribute_symbol, 'definition'].join('.')
  end

  class_methods do
    ALL_ATTRIBUTES = [
      {name: :abbreviation},
      {name: :full_name},
      {name: :current_version},
      {name: :linkages_and_extensions},
      {name: :development_year},
      {name: :programming_language, picklist: true, multiple: true},
      {name: :maintainer_type, picklist: true},
      {name: :maintainer_name},
      {name: :license, picklist: true},
      {name: :license_detailed},
      {name: :availability, picklist: true},
      {name: :expertise, picklist: true},
      {name: :expertise_detailed},
      {name: :platform, picklist: true, multiple: true},
      {name: :platform_detailed},
      {name: :category, picklist: true},
      {name: :category_detailed},
      {name: :hybrid_classification, picklist: true},
      {name: :hybrid_classification_detailed},
      {name: :purpose_or_objective},
      {name: :description},
      {name: :key_usage, picklist: true, multiple: true},
      {name: :scenario_coverage, picklist: true},
      {name: :scenario_coverage_details, picklist: true, multiple: true},
      {name: :geographic_coverage, picklist: true},
      {name: :geographic_coverage_region, picklist: true, multiple: true},
      {name: :geographic_coverage_country, picklist: true, multiple: true},
      {name: :sectoral_coverage, picklist: true, multiple: true},
      {name: :gas_and_pollutant_coverage, picklist: true, multiple: true},
      {name: :policy_coverage, picklist: true, multiple: true},
      {name: :technology_coverage, picklist: true, multiple: true},
      {name: :technology_coverage_detailed},
      {name: :energy_resource_coverage, picklist: true, multiple: true},
      {name: :time_horizon, picklist: true},
      {name: :time_step, picklist: true},
      {name: :equilibrium_type, picklist: true},
      {name: :foresight, picklist: true},
      {name: :spatial_resolution},
      {name: :population_assumptions},
      {name: :gdp_assumptions},
      {name: :other_assumptions},
      {name: :base_year},
      {name: :input_data},
      {name: :calibration_and_validation},
      {name: :languages, picklist: true, multiple: true},
      {name: :tutorial_and_training_opportunities, picklist: true, multiple: true},
      {name: :system_requirements},
      {name: :run_time},
      {name: :publications_and_notable_projects},
      {name: :citation},
      {name: :url},
      {name: :point_of_contact}
    ]

    PICKLIST_ATTRIBUTES = Set.new(
      ALL_ATTRIBUTES.select { |a| a[:picklist] == true }.map { |a| a[:name] }
    )

    MULTIPLE_ATTRIBUTES = Set.new(
      ALL_ATTRIBUTES.select { |a| a[:multiple] == true }.map { |a| a[:name] }
    )

    def attribute_symbols
      ALL_ATTRIBUTES.map { |a| a[:name] }
    end

    def attribute_symbols_for_strong_params
      ALL_ATTRIBUTES.map do |a|
        if a[:multiple]
          {a[:name] => []}
        else
          a[:name]
        end
      end
    end

    def is_picklist_attribute?(attribute_symbol)
      PICKLIST_ATTRIBUTES.include?(attribute_symbol)
    end

    def is_multiple_attribute?(attribute_symbol)
      MULTIPLE_ATTRIBUTES.include?(attribute_symbol)
    end
  end
end
