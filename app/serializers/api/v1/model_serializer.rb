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
      attribute :programming_language
      attribute :maintainer_institute
      attribute :license
      attribute :expertise
      attribute :base_year
      attribute :time_step
      attribute :time_horizon
      attribute :platform
      attribute :sectoral_coverage
      attribute :geographic_coverage
      attribute :url
      attribute :policy_coverage
      attribute :scenario_coverage
      attribute :gas_and_pollutant_coverage
      attribute :technology_coverage
      attribute :energy_resource_coverage
      attribute :equilibrium_type
      attribute :population_assumptions
      attribute :gdp_assumptions
      attribute :other_assumptions
      attribute :input_data
      attribute :publications_and_notable_projects
      attribute :point_of_contact
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
      attribute :logo

      attribute :scenario_ids
      attribute :indicator_ids

      def indicator_ids
        object.indicators.pluck(:id)
      end

      def scenario_ids
        object.scenarios.pluck(:id)
      end

      def logo
        object.logo_file_name ?
          object.logo.url(:original) :
          object.team && object.team.image_file_name && object.team.image.url(:original)
      end
    end
  end
end
