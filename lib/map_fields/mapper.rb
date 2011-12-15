require 'csv'
require 'tempfile'
require 'map_fields/mapping'

module MapFields
  class Mapper
    def initialize(controller, fields, file)
      @fields = get_fields(controller, fields)

      if file
        file = save_file controller, file
        @rows = parse_first_few_lines file
      else
        @mapped = true
        @rows = map_fields(controller, fields)
      end
    end
    attr_reader :rows, :fields

    def mapped?
      @mapped
    end

    private
    def map_fields(controller, fields)
      field_mapping = controller.params.delete(:mapped_fields)
      ignore_first_row = field_mapping.delete(:ignore_first_row)
      mapping = Mapping.new(field_mapping, fields)
      CSVReader.new(controller.session[:map_fields_file], mapping, ignore_first_row)
    end

    def get_fields(controller, fields)
      if fields.is_a?(Symbol)
        controller.send(fields)
      elsif fields.respond_to?(:call)
        fields.call
      else
        fields
      end
    end

    def save_file(controller, file)
      Tempfile.open(['map_fields', '.csv']) do |tmpfile|
        tmpfile.write file.read
        controller.session[:map_fields_file] = tmpfile.path
        tmpfile.path
      end
    end

    def parse_first_few_lines(file)
      rows = []
      rowcount = 0
      CSV.foreach(file) do |row|
        rows << row
        break if (rowcount += 1) >= 10
      end
      rows
    end
  end

  class CSVReader
    def initialize(file, mapping, ignore_first_row)
      @mapping = mapping
      @ignore_first_row = ignore_first_row
      @csv = CSV.open(file, :headers => ignore_first_row)
      @rows = nil
    end

    def [](index)
      get_row index
    end

    def each(&block)
      @csv.each do |row|
        block.call CSVRow.new(row, @mapping)
      end
    end

    private
    def get_row(index)
      CSVRow.new((@rows ||= parse_csv)[index], @mapping)
    end

    def parse_csv
      @csv.read
    end
  end

  class CSVRow
    def initialize(row, mapping)
      @row = row
      @mapping = mapping
    end

    def [](index)
      @row[@mapping[index]]
    end
  end
end
