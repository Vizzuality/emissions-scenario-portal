class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def get_order_type(orders, order_type)
      orders.include?(order_type) && order_type
    end

    def get_order_direction(direction)
      direction == 'desc' ? :desc : :asc
    end
  end
end
