class TemplatesController < ApplicationController
  def show
    available_templates = {
      "indicators" => IndicatorsUploadTemplate,
      "models" => ModelsUploadTemplate,
      "scenarios" => ScenariosUploadTemplate,
      "time_series_values" => TimeSeriesValuesUploadTemplate
    }

    template = available_templates[params[:id]].try(:new)
    raise ActiveRecord::RecordNotFound if template.nil?

    send_data(
      template.export,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=#{template.class.name.underscore}.csv"
    )
  end
end
