# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      class EmissionPathwaysController < ApiController
        include Streamable
        before_action :parametrise_filter, only: [:index, :download]
        before_action :parametrise_metadata_filter, only: [:download]

        def index
          @records = paginate @filter.call

          render json: @records,
                 adapter: :json,
                 each_serializer: Api::V1::Data::EmissionPathwaysSerializer,
                 params: params,
                 root: :data,
                 meta: @filter.meta
        end

        def meta
          set_links_header(
            [
              :locations, :models, :scenarios, :categories, :indicators
            ].map do |resource|
              {
                link: "/api/v1/data/emission_pathways/#{resource}",
                rel: "meta #{resource}"
              }
            end
          )
        end

        # rubocop:disable Metrics/MethodLength
        def download
          filename = 'emission_pathways'
          models_filename = 'models.csv'
          scenarios_filename = 'scenarios.csv'
          zipped_download = Api::V1::Data::ZippedDownload.new(filename)
          zipped_download.add_file_content(
            Api::V1::Data::EmissionPathwaysCsvContent.new(@filter).call,
            filename + '.csv'
          )
          zipped_download.add_file_content(
            Api::V1::Data::ModelsCsvContent.new(@models_filter).call,
            models_filename
          )
          zipped_download.add_file_content(
            Api::V1::Data::ScenariosCsvContent.new(@scenarios_filter).call,
            scenarios_filename
          )
          stream_file(filename) { zipped_download.call }
        end
        # rubocop:enable Metrics/MethodLength

        private

        def parametrise_filter
          @filter = Data::EmissionPathwaysFilter.new(params)
        end

        def parametrise_metadata_filter
          @models_filter = Api::V1::Data::ModelsFilter.new(
            params.slice(:model_ids, :location_ids)
          )
          @scenarios_filter = Api::V1::Data::ScenariosFilter.new(
            params.slice(:model_ids, :scenario_ids, :location_ids)
          )
        end

        # rubocop:disable Naming/AccessorMethodName
        def set_caching_headers
          return true if Rails.env.development?
          expires_in 2.hours, public: true
        end

        # @param links_with_rels [Array<Hash>]
        def set_links_header(links_with_rels)
          links = (headers['Link'] || '').split(',').map(&:strip)
          links_with_rels.each do |link_with_rel|
            links << %(<#{link_with_rel[:link]}>; rel="#{link_with_rel[:rel]}")
          end
          headers['Link'] = links.join(', ')
        end
        # rubocop:enable Naming/AccessorMethodName
      end
    end
  end
end
