module IndicatorsHelper
  def types_for_select
    options = [['Core indicators', 'core']]
    options +=
      if current_user.admin?
        Team.all.map do |t|
          ["Variations added by team: #{t.name}", "team-#{t.id}"]
        end
      else
        [['Variations added by your team', "team-#{current_user.team_id}"]]
      end
    options_for_select(options)
  end

  def categories_for_select
    options_for_select(
      Indicator.order(:category).distinct.pluck(:category)
    )
  end

  def destroy_confirmation_message(indicator)
    time_series_data = 'Time series data exists for this indicator. '
    message = 'Are you sure you want to proceed?'
    message.prepend time_series_data if indicator.time_series_data?
    message
  end
end
