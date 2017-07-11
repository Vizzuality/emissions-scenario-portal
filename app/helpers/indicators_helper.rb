module IndicatorsHelper
  def types_for_select
    options = [
      ['System indicators', 'system']
    ]
    options +=
      if current_user.admin?
        Team.all.map do |t|
          ["Indicators added by team: #{t.name}", "team-#{t.id}"]
        end
      else
        [
          ['Indicators added by your team', "team-#{current_user.team_id}"],
          ['Indicators added by other teams', "other-#{current_user.team_id}"]
        ]
      end
    options_for_select(options)
  end

  def categories_for_select
    options_for_select(
      Indicator.order(:category).distinct.pluck(:category)
    )
  end

  def values_for_indicator_parent_dropdown(indicator)
    selection = indicator.parent
    select_values = Indicator.where('parent_id IS NULL').select(:id, :alias).
      map do |i|
        [i.alias, i.id]
      end
    [select_values, selection, action_name == 'fork']
  end

  def destroy_confirmation_message(indicator)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if indicator.time_series_data?
    message
  end
end
