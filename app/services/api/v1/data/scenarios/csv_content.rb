require 'csv'

module Api
  module V1
    module Data
      module Scenarios
        class CsvContent
          def initialize(filter)
            @query = filter.call
            @headers = %w(Model Scenario Property Value)
            @attribute_infos = ScenariosData::PROPERTY_NAMES.map do |property|
              Scenario.attribute_info(property)
            end
            @attribute_infos = @attribute_infos.reject(&:reference?)
          end

          def call
            CSV.generate do |output|
              output << @headers
              @query.each do |record|
                record_properties(record).each do |row|
                  output << row
                end
              end
            end
          end

          private

          # rubocop:disable Metrics/MethodLength
          def record_properties(record)
            result = []
            @attribute_infos.map do |attribute_info|
              raw_value = record[attribute_info.name]
              next if raw_value.blank?
              value =
                if attribute_info.multiple?
                  raw_value.join(', ')
                else
                  raw_value
                end
              result << [
                record.model.abbreviation,
                record.name,
                attribute_info.name.to_s.humanize,
                value
              ]
            end
            result
          end
          # rubocop:enable Metrics/MethodLength
        end
      end
    end
  end
end
