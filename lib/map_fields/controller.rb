require 'map_fields/mapper'

module MapFields
  module Controller
    def map_fields(fields, file, options={}, &block)
      append_view_path File.expand_path('../../../views/', __FILE__)
      @mapper = Mapper.new(self, fields, file, options)
      if @mapper.mapped?
        block.call(@mapper)
      else
        render
      end
    end
  end
end
