class DeleteVariations < ActiveRecord::Migration[5.1]
  class Indicator < ApplicationRecord; end

  def change
    Indicator.where.not(parent_id: nil).delete_all
  end
end
