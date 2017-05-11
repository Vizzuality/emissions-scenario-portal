module MetadataAttributes
  def self.included(base)
    base.class_eval do
      def self.attribute_symbols
        self::ALL_ATTRIBUTES.map { |a| a['name'] }
      end

      def self.attribute_symbols_for_strong_params
        self::ALL_ATTRIBUTES.map do |a|
          if a['multiple']
            {a['name'] => []}
          else
            a['name']
          end
        end
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

      def self.attributes_with_flag_set(flag_name)
        self::ALL_ATTRIBUTES.select do |a|
          a[flag_name] == true
        end
      end
    end
  end

  def key_for_name(attribute_symbol)
    ['models', attribute_symbol, 'name'].join('.')
  end

  def key_for_definition(attribute_symbol)
    ['models', attribute_symbol, 'definition'].join('.')
  end
end
