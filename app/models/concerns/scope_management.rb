require 'active_support/concern'

module ScopeManagement
  extend ActiveSupport::Concern

  included do
    before_save :promote_parent_to_system_indicator, if: proc { |i|
      i.parent.present? && i.parent.team_id.present?
    }
  end

  def scope
    if parent_id.blank? && team_id.blank?
      :system_indicator
    elsif parent_id.blank?
      :team_indicator
    else
      :team_variation
    end
  end

  def variation?
    scope == :team_variation
  end

  def fork_variation(variation_attributes)
    indicator = dup
    indicator.parent = self
    indicator.attributes = variation_attributes
    indicator.auto_generated = true
    indicator
  end

  def fork_system_indicator
    system_indicator = dup
    system_indicator.team_id = nil
    system_indicator.parent_id = nil
    system_indicator.auto_generated = true
    system_indicator
  end

  def promote_to_system_indicator
    system_indicator = fork_system_indicator
    new_parent = create_parent(system_indicator.attributes)
    new_parent.variations << self
    new_parent
  end

  def promote_parent_to_system_indicator
    system_indicator = parent.promote_to_system_indicator
    self.parent = system_indicator
  end
end
