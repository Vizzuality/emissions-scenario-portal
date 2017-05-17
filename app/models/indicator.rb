class Indicator < ApplicationRecord
  ALL_ATTRIBUTES = YAML.load_file(
    Rails.root.join('db', 'indicators_metadata.yml')
  ).freeze
  include MetadataAttributes

  validates :name, presence: true

  class << self
    def fetch_all(order_options)
      order_direction = order_options['order_direction'].present? && order_options['order_direction'] == 'desc' ? :desc : :asc

      case order_options['order_type']
        when 'category'
          indicators = Indicator.order(category: order_direction, name: :asc)
        when 'stack_family'
          indicators = Indicator.order(stack_family: order_direction, name: :asc)
        when 'definition'
          indicators = Indicator.order(definition: order_direction, name: :asc)
        when 'unit'
          indicators = Indicator.order(unit: order_direction, name: :asc)
        else
          indicators = Indicator.order(name: order_direction)
      end

      indicators
    end
  end

  # TODO: validate comparable indicator has convertible unit
  # TODO: unit conversions
end
