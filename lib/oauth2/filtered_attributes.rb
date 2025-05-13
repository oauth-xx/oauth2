module OAuth2
  module FilteredAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def filtered_attributes(*attributes)
        @filtered_attribute_names = attributes.map(&:to_sym)
      end

      def filtered_attribute_names
        @filtered_attribute_names || []
      end
    end

    def inspect
      filtered_attribute_names = self.class.filtered_attribute_names
      return super if filtered_attribute_names.empty?

      inspected_vars = instance_variables.map do |var|
        if filtered_attribute_names.any? { |filtered_var| var.to_s.include?(filtered_var.to_s) }
          "#{var}=[FILTERED]"
        else
          "#{var}=#{instance_variable_get(var).inspect}"
        end
      end
      "#<#{self.class}:#{object_id} #{inspected_vars.join(", ")}>"
    end
  end
end
