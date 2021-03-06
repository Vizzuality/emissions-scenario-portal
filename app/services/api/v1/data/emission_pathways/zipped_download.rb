module Api
  module V1
    module Data
      module EmissionPathways
        class ZippedDownload
          attr_reader :filename

          def initialize(filter, params)
            @filter = filter
            initialize_metadata_filter(params)

            @filename = 'emission_pathways'
            @models_filename = 'models.csv'
            @scenarios_filename = 'scenarios.csv'
          end

          def call
            zipped_download = Api::V1::Data::ZippedDownload.new(@filename)
            zipped_download.add_file_content(
              Api::V1::Data::EmissionPathways::CsvContent.new(@filter).call,
              @filename + '.csv'
            )
            zipped_download.add_file_content(
              Api::V1::Data::Models::CsvContent.new(@models_filter).call,
              @models_filename
            )
            zipped_download.add_file_content(
              Api::V1::Data::Scenarios::CsvContent.new(@scenarios_filter).call,
              @scenarios_filename
            )
            zipped_download.call
          end

          private

          def initialize_metadata_filter(params)
            @models_filter = Api::V1::Data::Models::Filter.new(
              params.slice(:model_ids, :location_ids)
            )
            @scenarios_filter = Api::V1::Data::Scenarios::Filter.new(
              params.slice(:model_ids, :scenario_ids, :location_ids)
            )
          end
        end
      end
    end
  end
end
