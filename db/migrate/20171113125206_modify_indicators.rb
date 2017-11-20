class ModifyIndicators < ActiveRecord::Migration[5.1]
  class Category < ApplicationRecord
    belongs_to :parent, class_name: 'Category', foreign_key: 'parent_id', optional: true
    has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  end

  class Indicator < ApplicationRecord
    belongs_to :the_category, class_name: 'Category', foreign_key: 'category_id'
    belongs_to :the_subcategory, class_name: 'Category', foreign_key: 'subcategory_id', optional: true
  end

  def change
    add_reference :indicators, :category, foreign_key: {
      to_table: :categories
    }
    add_reference :indicators, :subcategory, foreign_key: {
      to_table: :categories
    }
    migrate_data
    remove_column :indicators, :category, :string
    remove_column :indicators, :subcategory, :string
    remove_column :indicators, :stackable_subcategory, :boolean
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
            stackable: !!ind[:stackable_subcategory],
            parent: category
          )
        end
      end

      unless category.nil? && subcategory.nil?
        ind.category_id = category.id
        ind.subcategory_id = subcategory.id unless subcategory.nil?
        ind.save!
      end
    end
  end

  def migrate_data_down
    Indicator.includes(the_category: :parent).all.each do |ind|
      ind.category = ind.the_category.name if ind.the_category
      ind.subcategory = ind.the_subcategory.name if ind.the_subcategory
      ind.stackable_subcategory = ind.the_subcategory.stackable if ind.the_subcategory
      ind.save! if (ind.the_category || ind.the_subcategory)
    end
  end
end
