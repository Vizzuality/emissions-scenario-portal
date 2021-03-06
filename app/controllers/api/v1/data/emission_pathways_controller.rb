# Used in ClimateWatch Data Explorer
module Api
  module V1
    module Data
      class EmissionPathwaysController < ApiController
        include Streamable
        before_action :parametrise_filter, only: [:index, :download]

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

        def download
          zipped_download =
            Api::V1::Data::EmissionPathways::ZippedDownload.new(
              @filter,
              source_ids: params[:source_ids]
            )
          stream_file(zipped_download.filename) { zipped_download.call }
        end

        private

        def parametrise_filter
          @filter = Data::EmissionPathways::Filter.new(params)
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
