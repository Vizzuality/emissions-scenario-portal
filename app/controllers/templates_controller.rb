class TemplatesController < ApplicationController
  def show
    model = Model.find_by(id: params[:model_id])

    available_templates = {
      "indicators" => IndicatorsUploadTemplate,
      "models" => ModelsUploadTemplate,
      "scenarios" => ScenariosUploadTemplate,
      "time_series_values" => TimeSeriesValuesUploadTemplate,
      "notes" => NotesUploadTemplate
    }

    template = available_templates[params[:id]].try(:new)
    template.model = model if template.respond_to?(:model=)
    template.user = current_user if template.respond_to?(:user=)
    raise ActiveRecord::RecordNotFound if template.nil?

    send_data(
      ActiveSupport::Inflector.transliterate(template.export, ' '),
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=#{template.class.name.underscore}.csv"
    )
  end
end
