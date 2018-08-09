require 'csv'

module Api
  module V1
    module Data
      class EmissionPathwaysCsvContent
        def initialize(filter)
          @grouped_query = filter.call
          # FIXME: Should we just remove the columns we don't want by name?
          @headers = filter.column_aliases[1...-1]
          @years = filter.years
        end

        def call
          CSV.generate do |csv|
            csv << @headers.map(&:humanize) + @years
            @grouped_query.each do |record|
              ary = @headers.map { |h| record[h] }
              ary += @years.map do |y|
                emission = record.emissions.find { |e| e['year'] == y }
                (emission && emission['value']) || 'N/A'
              end
              csv << ary
            end
          end
        end
      end
    end
  end
end
