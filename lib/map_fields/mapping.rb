module MapFields
  class Mapping
    def initialize(mapping, fields)
      @mapping = mapping
      @fields = fields

      @mapping = mapping.each_with_object({}){ |arr, hash|
        key = arr[0].to_i
        value = arr[1].to_i

        hash[key] = value
        hash[@fields[key]] = value
        hash[field_to_symbol(@fields[key])] = value
      }
    end

    def [](index)
      @mapping[index]
    end

    private
    def field_to_symbol(field)
      field.to_s.downcase.gsub(/[^a-z0-9]+/, '_').to_sym
    end
  end
end
