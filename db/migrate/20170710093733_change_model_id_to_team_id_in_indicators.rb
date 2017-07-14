class ChangeModelIdToTeamIdInIndicators < ActiveRecord::Migration[5.0]
  def up
    add_reference :indicators, :team, index: true, foreign_key: true
    execute 'UPDATE indicators SET team_id = models.team_id FROM models WHERE models.id = indicators.model_id'
    remove_column :indicators, :model_id
  end

  def down
    add_reference :indicators, :model, index: true, foreign_key: true
    Indicator.where('team_id IS NOT NULL').each do |i|
      i.model_id = i.team.models.first.try(:id)
      i.save
    end
    remove_column :indicators, :team_id
  end
end
