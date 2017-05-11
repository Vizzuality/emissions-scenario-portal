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
        @@picklist_attributes ||= Set.new(
          self::ALL_ATTRIBUTES.select { |a| a['picklist'] == true }.map { |a| a['name'] }
        )
        @@picklist_attributes.include?(attribute_symbol)
      end

      def self.multiple_attribute?(attribute_symbol)
        @@multiple_attributes ||= Set.new(
          self::ALL_ATTRIBUTES.select { |a| a['multiple'] == true }.map { |a| a['name'] }
        )
        @@multiple_attributes.include?(attribute_symbol)
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
