class ChangeProgrammingLanguageFromArrayToText < ActiveRecord::Migration[5.0]
  def change
    change_column :models, :programming_language, :text, default: nil
  end
end
