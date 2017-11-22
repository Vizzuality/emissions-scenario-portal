module OrderableFilter
  attr_writer :order_type, :order_direction

  def order_type
    @order_type if order_columns.include?(@order_type)
  end

  def order_direction
    @order_direction.to_s.casecmp('desc').zero? ? :desc : :asc
  end
end
