require 'active_support/concern'

module ModelAttributes
  extend ActiveSupport::Concern

  included do
    validates :abbreviation, presence: true, uniqueness: true
    validates :full_name, presence: true
  end

  # def key_for_name(attribute_symbol)
  #   ['models', attribute_symbol, 'name'].join('.')
  # end

  # def key_for_definition(attribute_symbol)
  #   ['models', attribute_symbol, 'definition'].join('.')
  # end

  # class_methods do

  #   def attributes_list
  #     [
  #       :abbreviation,
  #       :full_name
  #     ]
  #   end
  # end
end
