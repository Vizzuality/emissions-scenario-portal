module Api
  module V1
    class ScenarioSerializer < ActiveModel::Serializer
      attribute :id
      attribute :name
      attribute :model_abbreviation
      attribute :category
      attribute :description
      attribute :geographic_coverage_country
      attribute :sectoral_coverage
      attribute :gas_and_pollutant_coverage
      attribute :policy_coverage
      attribute :policy_coverage_detailed
      attribute :technology_coverage
      attribute :technology_coverage_detailed
      attribute :energy_resource_coverage
      attribute :time_horizon
      attribute :time_step
      attribute :climate_target_type
      attribute :large_scale_bioccs
      attribute :technology_assumptions
      attribute :gdp_assumptions
      attribute :population_assumptions
      attribute :discount_rates
      attribute :emission_factors
      attribute :global_warming_potentials
      attribute :policy_cut_off_year_for_baseline
      attribute :literature_reference
      attribute :purpose_or_objective
      attribute :key_usage
      attribute :project
      attribute :climate_target_detailed
      attribute :climate_target_date
      attribute :overshoot
      attribute :other_target_type
      attribute :other_target
      attribute :burden_sharing
      attribute :indicators

      belongs_to :model

      def model
        {
          id: object.model.id,
          name: object.model.full_name
        }
      end

      def indicators
        object.indicators.map(&:id)
      end
    end
  end
end
