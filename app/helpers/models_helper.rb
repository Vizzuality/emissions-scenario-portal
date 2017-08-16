module ModelsHelper
  def model_destroy_confirmation_message(model)
    scenarios = 'Scenarios exist for this model. '
    message = 'Are you sure you want to proceed?'
    message.prepend scenarios if model.scenarios?
    message
  end
end
