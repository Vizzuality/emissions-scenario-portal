require 'active_support/concern'

module BestEffortMatching
  extend ActiveSupport::Concern

  class_methods do
    def best_effort_matches(indicator_name, model)
      indicator_name = indicator_name.downcase
      # best match: variation or team indicator with matching alias and model
      indicators = Indicator.where(model_id: model.id)
                     .where('lower(alias) = ?', indicator_name)
      if indicators.none?
        # second best: variation with matching model and parent matching alias
        indicators = variations_with_matching_parent(indicator_name, model)
      end
      if indicators.none?
        # third best: system indicator with matching alias
        indicators = matching_system_indicators(indicator_name)
      end
      if indicators.none?
        # fourth best: another model's team indicator with matching alias
        indicators = matching_team_indicators(indicator_name)
      end
      if indicators.none?
        # last resort: system indicator that has variation with matching alias
        indicators = system_indicators_with_matching_variations(indicator_name)
      end

      indicators
    end

    def variations_with_matching_parent(indicator_name, model)
      Indicator.joins(:parent).
        where(model_id: model.id).
        where('lower(parents_indicators.alias) = ?', indicator_name)
    end

    def matching_system_indicators(indicator_name)
      Indicator.where(parent_id: nil, model_id: nil).
        where('lower(alias) = ?', indicator_name)
    end

    def matching_team_indicators(indicator_name)
      Indicator.where(parent_id: nil).
        where('lower(alias) = ?', indicator_name).
        where('model_id IS NOT NULL')
    end

    def system_indicators_with_matching_variations(indicator_name)
      Indicator.where(parent_id: nil).
        joins(:variations).
        where('lower(variations_indicators.alias) = ?', indicator_name)
    end
  end
end
