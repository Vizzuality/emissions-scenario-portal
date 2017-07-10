class ChangeModelIdToTeamIdInIndicators < ActiveRecord::Migration[5.0]
  def change
    add_reference :indicators, :team, index: true, foreign_key: true
    execute 'UPDATE indicators SET team_id = models.team_id FROM models WHERE models.id = indicators.model_id'
    remove_column :indicators, :model_id
  end
end
