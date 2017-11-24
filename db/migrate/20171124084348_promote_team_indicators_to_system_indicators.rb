class PromoteTeamIndicatorsToSystemIndicators < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord; end

  def change
    Indicator.update_all(model_id: nil)
  end
end
