module MapFields
  class ParamsParser
    def self.parse(params, field = nil)
      result = []
      params.each do |key, value|
        next if [:controller, :action].include?(key.to_sym)
        if field.nil? || field.to_s == key.to_s
          check_values(value) do |k,v|
            result << ["#{key.to_s}#{k}", v]
          end
        end
      end
      result
    end

    private
    def self.check_values(value, &block)
      result = []
      if value.kind_of?(Hash)
        value.each do |k,v|
          check_values(v) do |k2,v2|
            result << ["[#{k.to_s}]#{k2}", v2]
          end
        end
      elsif value.kind_of?(Array)
        value.each do |v|
          check_values(v) do |k2, v2|
            result << ["[]#{k2}", v2]
          end
        end
      else
        result << ["", value] unless value.respond_to?(:read)
      end
      result.each do |arr|
        yield arr[0], arr[1]
      end
    end
  end
end
