module MetadataAttributes
  def self.included(base)
    base.class_eval do
      def ignore_blank_array_values
        self.class.attributes_with_flag_set('picklist').map do |a|
          value = read_attribute(a['name'])
          value = convert_from_array(value) if !a['multiple'] && value.present?
          next unless value.is_a?(Array) && value.any?
          if a['multiple']
            write_attribute(a['name'], value.reject(&:blank?))
          else
            write_attribute(a['name'], value.reject(&:blank?).first)
          end
        end
      end

      def convert_from_array(value_str)
        JSON.parse(value_str)
      rescue JSON::ParserError
        value_str
      end

      def self.attribute_symbols
        self::ALL_ATTRIBUTES.map { |a| a['name'] }
      end

      def self.attribute_symbols_for_strong_params
        self::ALL_ATTRIBUTES.map { |a| attribute_symbol_for_strong_params(a) }
      end

      def self.attribute_symbol_for_strong_params(attribute_info)
        name =
          if attribute_info['reference'].present?
            ref_object_symbol = attribute_info['reference'].split('.').first
            ref_object_symbol + '_id'
          else
            attribute_info['name']
          end
        attribute_info['picklist'] ? {name => []} : name
      end

      def self.picklist_attribute?(attribute_symbol)
        @picklist_attributes ||= Set.new(
          attributes_with_flag_set('picklist').map { |a| a['name'] }
        )
        @picklist_attributes.include?(attribute_symbol)
      end

      def self.multiple_attribute?(attribute_symbol)
        @multiple_attributes ||= Set.new(
          attributes_with_flag_set('multiple').map { |a| a['name'] }
        )
        @multiple_attributes.include?(attribute_symbol)
      end

      def self.date_attribute?(attribute_symbol)
        @date_attributes ||= Set.new(
          attributes_with_flag_set('date').map { |a| a['name'] }
        )
        @date_attributes.include?(attribute_symbol)
      end

      def self.size_attribute(attribute_symbol)
        (info = attribute_info(attribute_symbol)) && info['size']
      end

      def self.category_attribute(attribute_symbol)
        (info = attribute_info(attribute_symbol)) && info['category'] ||
          'Miscellany'
      end

      def self.reference_attribute(attribute_symbol)
        (info = attribute_info(attribute_symbol)) && info['reference']
      end

      def self.attributes_with_flag_set(flag_name)
        self::ALL_ATTRIBUTES.select do |a|
          a[flag_name] == true
        end
      end

      def self.attribute_info(attribute_symbol)
        self::ALL_ATTRIBUTES.find { |a| a['name'] == attribute_symbol }
      end
    end
  end

  def key_for_name(attribute_symbol)
    [self.class.name.downcase.pluralize, attribute_symbol, 'name'].join('.')
  end

  def key_for_definition(attribute_symbol)
    [
      self.class.name.downcase.pluralize, attribute_symbol, 'definition'
    ].join('.')
  end
end
