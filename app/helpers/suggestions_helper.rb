module SuggestionsHelper
  SUGGESTIONS = {
    'indicator|blank' =>
    'Please ensure that the given indicator name is correct',
    'model|blank' =>
    'Please ensure that the given model name is correct and that you have permissions to use it'
  }

  def suggestion(error)
    suggestion =
      SUGGESTIONS[error.values_at('type', 'col', 'error').join('|')] ||
      SUGGESTIONS[error.values_at('col', 'error').join('|')]

    suggestion.try(:html_safe)
  end
end
