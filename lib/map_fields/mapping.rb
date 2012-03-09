module MapFields
  class Mapping
    def initialize(mapping, fields)
      @mapping = mapping
      @fields = fields

      @mapping = mapping.each_with_object({}){ |arr, hash|
        key = arr[1].blank? ? nil : arr[1].to_i
        next if key.nil?
        value = arr[0].blank? ? nil : arr[0].to_i

        hash[key] = value
        hash[@fields[key]] = value
        hash[field_to_symbol(@fields[key])] = value
      }
    end
    attr_reader :mapping

    def [](index)
      @mapping[index]
    end

    def is_mapped?(key)
      @mapping.has_key?(key)
    end

    def selected_mapping(column)
      @mapping.find{|k, v| return k if v == column && k.is_a?(Numeric) }
    end

    private
    def field_to_symbol(field)
      field.to_s.downcase.gsub(/[^a-z0-9]+/, '_').to_sym
    end
  end
end
