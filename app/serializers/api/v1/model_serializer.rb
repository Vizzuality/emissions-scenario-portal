module Api
  module V1
    class ModelSerializer < ActiveModel::Serializer
      attribute :id
      attribute :full_name
      attribute :description
      attribute :citation
      attribute :key_usage
      attribute :abbreviation
      attribute :current_version
      attribute :development_year
      attribute :programming_language
      attribute :maintainer_name
      attribute :license
      attribute :availability
      attribute :expertise
      attribute :expertise_detailed
      attribute :platform
      attribute :purpose_or_objective
      attribute :base_year
      attribute :time_step
      attribute :time_horizon
      attribute :sectoral_coverage
      attribute :geographic_coverage
      attribute :geographic_coverage_country
      attribute :url
      attribute :policy_coverage
      attribute :policy_coverage_detailed
      attribute :scenario_coverage
      attribute :scenario_coverage_detailed
      attribute :gas_and_pollutant_coverage
      attribute :technology_coverage
      attribute :technology_coverage_detailed
      attribute :energy_resource_coverage
      attribute :equilibrium_type
      attribute :spatial_resolution
      attribute :population_assumptions
      attribute :gdp_assumptions
      attribute :other_assumptions
      attribute :input_data
      attribute :publications_and_notable_projects
      attribute :point_of_contact
      attribute :parent_model
      attribute :descendent_models
      attribute :concept
      attribute :solution_method
      attribute :anticipation
      attribute :behaviour
      attribute :land_use
      attribute :technology_choice
      attribute :global_warming_potentials
      attribute :technology_constraints
      attribute :trade_restrictions
      attribute :solar_power_supply
      attribute :wind_power_supply
      attribute :bioenergy_supply
      attribute :co2_storage_supply

      attribute :scenario_ids
      attribute :indicator_ids

      def indicator_ids
        object.indicators.pluck(:id)
      end

      def scenario_ids
        object.scenarios.pluck(:id)
      end
    end
  end
end
