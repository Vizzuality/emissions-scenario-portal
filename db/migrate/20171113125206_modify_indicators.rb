class ModifyIndicators < ActiveRecord::Migration[5.1]
  class Category < ApplicationRecord
    belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id', optional: true
    has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  end

  class Indicator < ApplicationRecord
    belongs_to :the_category, class_name: 'Category', foreign_key: 'category_id'
  end

  def change
    add_reference :indicators, :category, foreign_key: {
      to_table: :categories
    }
    migrate_data
    remove_column :indicators, :category, :string
    remove_column :indicators, :subcategory, :string
  end

  private

  def migrate_data
    reversible do |dir|
      dir.up do
        say_with_time 'migrate_data' do
          migrate_data_up
        end
      end

      dir.down do
        say_with_time 'migrate_data' do
          migrate_data_down
        end
      end
    end
  end

  def migrate_data_up
    Indicator.all.each do |ind|
      unless ind[:category].blank?
        category = Category.find_or_create_by!(
          name: ind[:category]
        )

        unless ind[:subcategory].blank?
          subcategory = Category.find_or_create_by!(
            name: ind[:subcategory],
            parent: category
          )
        end
      end

      unless category.nil? && subcategory.nil?
        ind.category_id = (subcategory || category).id
        ind.save!
      end
    end
  end

  def migrate_data_down
    Indicator.includes(the_category: :parent).all.each do |ind|
      if ind.the_category && ind.the_category.parent
        ind.category = ind.the_category.parent.name
        ind.subcategory = ind.the_category.name
        ind.save!
      elsif ind.the_category
        ind.category = ind.the_category.name
        ind.save!
      end
    end
  end
end
