class CreateExtensionTablefunc < ActiveRecord::Migration[5.0]
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS tablefunc'
  end

  def down; end
end
