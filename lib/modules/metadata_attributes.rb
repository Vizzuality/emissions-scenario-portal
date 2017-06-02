module MetadataAttributes
  class Info
    attr_reader :name, :size, :category, :ref_object_symbol, :ref_attr_symbol

    def initialize(options)
      @name = options['name']
      @input_type = [
        :reference, :picklist, :date, :checkbox
      ].find do |type|
        options[type.to_s].present?
      end || :text
      @reference = options['reference']
      if options['reference'].present?
        @ref_object_symbol, @ref_attr_symbol =
          options['reference'].split('.')
      end
      @multiple = options['multiple']
      @size = options['size']
      @category = options['category'] || 'Miscellany'
    end

    def reference?
      @input_type == :reference
    end

    def picklist?
      @input_type == :picklist
    end

    def multiple?
      @multiple.present?
    end

    def date?
      @input_type == :date
    end

    def checkbox?
      @input_type == :checkbox
    end

    def attribute_symbol_for_strong_params
      name =
        if reference?
          @ref_object_symbol + '_id'
        else
          @name
        end
      picklist? ? {name => []} : name
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def ignore_blank_array_values
    self.class.attribute_infos.select(&:picklist?).map do |a|
      value = read_attribute(a.name)
      value = convert_from_array(value) if !a.multiple? && value.present?
      next unless value.is_a?(Array) && value.any?
      if a.multiple?
        write_attribute(a.name, value.reject(&:blank?))
      else
        write_attribute(a.name, value.reject(&:blank?).first)
      end
    end
  end

  def convert_from_array(value_str)
    JSON.parse(value_str)
  rescue JSON::ParserError
    value_str
  end

  module ClassMethods
    def attribute_infos
      @attribute_infos ||= self::ALL_ATTRIBUTES.map { |a| Info.new(a) }
    end

    def attribute_symbols_for_strong_params
      attribute_infos.map(&:attribute_symbol_for_strong_params)
    end

    def attribute_info(attribute_symbol)
      attribute_infos.find { |a| a.name == attribute_symbol }
    end

    def key_for_name(attribute_symbol)
      [name.downcase.pluralize, attribute_symbol, 'name'].join('.')
    end

    def key_for_definition(attribute_symbol)
      [
        name.downcase.pluralize, attribute_symbol, 'definition'
      ].join('.')
    end
  end
end
