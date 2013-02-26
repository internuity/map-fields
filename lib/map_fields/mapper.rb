require 'csv'
require 'tempfile'
require 'map_fields/mapping'
require 'map_fields/params_parser'

module MapFields
  class MissingFileError < StandardError; end

  class Mapper
    def initialize(controller, fields, file, options={})
      @controller = controller
      params = controller.params
      @fields = get_fields(controller, fields)
      @params = ParamsParser.parse(params)
      @options = options

      if file
        file = save_file controller, file
        @rows = parse_first_few_lines file
      else
        raise MissingFileError unless controller.session[:map_fields_file] && File.exist?(controller.session[:map_fields_file])
        @mapped = true
        @rows = map_fields(controller, params.delete(:mapped_fields), @fields)
      end
    end
    attr_reader :rows, :fields, :params, :ignore_first_row

    def error!
      @mapped = false
      @rows = parse_first_few_lines @controller.session[:map_fields_file]
    end

    def mapping
      @mapping.mapping
    end

    def mapped?
      @mapped
    end

    def selected_mapping(column)
      @mapping ? @mapping.selected_mapping(column) : nil
    end

    def is_mapped?(key)
      @mapping ? @mapping.is_mapped?(key) : false
    end

    def fields_for_select
      result = []
      fields.each_with_index { |i,e| result << [i, e] }
      result
    end

    def each(&block)
      @rows.each &block
    end

    def file
      return nil unless @controller.session[:map_fields_file]
      UploadedFile.new(@controller.session[:map_fields_file], @controller.session[:map_fields_file_name])
    end

    private
    def map_fields(controller, mapped_fields, fields)
      @ignore_first_row = !!mapped_fields.delete(:ignore_first_row)
      @mapping = Mapping.new(mapped_fields, fields)
      CSVReader.new(controller.session[:map_fields_file], @mapping, @ignore_first_row, @options)
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
      path = Rails.root.join("tmp/map_fields_#{Time.now.to_i}_#{$$}")
      File.open(path, 'wb') do |tmpfile|
        tmpfile.write file.read
      end
      controller.session[:map_fields_file] = path
      controller.session[:map_fields_file_name] = file.respond_to?(:original_filename) ? file.original_filename : File.basename(file)
      path
    end

    def parse_first_few_lines(file)
      rows = []
      rowcount = 0
      CSV.foreach(file, encoding: @options[:encoding] || 'UTF-8') do |row|
        rows << row
        break if (rowcount += 1) >= 10
      end
      rows
    end
  end

  class CSVReader
    def initialize(file, mapping, ignore_first_row, options)
      @mapping = mapping
      @ignore_first_row = ignore_first_row
      @csv = CSV.open(file, :headers => ignore_first_row, encoding: options[:encoding] || 'UTF-8')
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

    def size
      @row.size
    end
  end

  class UploadedFile
    def initialize(file_path, original_filename)
      @file = File.open(file_path)
      @original_filename = original_filename
    end
    attr_reader :file, :original_filename

    def respond_to?(method_id, *args)
      super || file.respond_to?(method_id, *args)
    end

    def method_missing(method_id, *args, &block)
      file.send(method_id, *args, &block)
    end
  end
end
