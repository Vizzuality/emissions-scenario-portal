module IndicatorsHelper
  def types_for_select
    options_for_select(
      [
        ['Added by your team', 'team'],
        ['Added by anyone', 'all']
      ]
    )
  end

  def categories_for_select
    options_for_select(
      @indicators.except(:order).order(:category).distinct.pluck(:category)
    )
  end
end
