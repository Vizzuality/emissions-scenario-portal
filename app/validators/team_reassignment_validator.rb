class TeamReassignmentValidator < ActiveModel::Validator
  def validate(record)
    if record.team_id_was.present? &&
        record.team_id.present? &&
        record.team_id_was != record.team_id
      record.errors[:team] <<
        'Cannot reassign team, please remove from other team first.'
    end
  end
end
