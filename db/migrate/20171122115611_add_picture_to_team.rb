class AddPictureToTeam < ActiveRecord::Migration[5.1]
  def change
    add_attachment :teams, :image
  end
end
