require 'fastercsv'

module MapFields
  VERSION = '1.0.0'

  def self.included(base)
    base.extend(ClassMethods)
  end

  def map_fields
    default_options = {
      :file_field => 'file',
      :params => []
    }
    options = default_options.merge(
                self.class.read_inheritable_attribute(:map_fields_options)
              )

    RAILS_DEFAULT_LOGGER.debug("session[:map_fields]: #{session[:map_fields]}")
    RAILS_DEFAULT_LOGGER.debug("params[options[:file_field]]: #{params[options[:file_field]]}")
    if session[:map_fields].nil? || !params[options[:file_field]].blank?
      session[:map_fields] = {}
      if params[options[:file_field]].blank?
        @map_fields_error = MissingFileContentsError
        return
      end

      file_field = params[options[:file_field]]

      temp_path = File.join(Dir::tmpdir, "map_fields_#{Time.now.to_i}_#{$$}")
      File.open(temp_path, 'wb') do |f|
        f.write file_field.read
      end

      session[:map_fields][:file] = temp_path
    else
      if session[:map_fields][:file].nil? || params[:fields].nil?
        session[:map_fields] = nil
        @map_fields_error =  InconsistentStateError
      else
        expected_fields = self.class.read_inheritable_attribute(:map_fields_fields)
        if expected_fields.respond_to?(:call)
          expected_fields = expected_fields.call(params)
        end
        @mapped_fields = MappedFields.new(session[:map_fields][:file],
                                          expected_fields,
                                          params[:fields],
                                          params[:ignore_first_row])
      end
    end

    unless @map_fields_error
      @rows = []
      begin
        FasterCSV.foreach(session[:map_fields][:file]) do |row|
          @rows << row
          break if @rows.size == 10
        end
      rescue FasterCSV::MalformedCSVError => e
        @map_fields_error = e
      end
      expected_fields = self.class.read_inheritable_attribute(:map_fields_fields)
      if expected_fields.respond_to?(:call)
        expected_fields = expected_fields.call(params)
      end
      @fields = ([nil] + expected_fields).inject([]){ |o, e| o << [e, o.size]}
      @parameters = []
      options[:params].each do |param|
        @parameters += ParamsParser.parse(params, param)
      end
    end
  end

  def mapped_fields
    @mapped_fields
  end

  def fields_mapped?
    raise @map_fields_error if @map_fields_error
    @mapped_fields
  end

  def map_field_parameters(&block)

  end

  def map_fields_cleanup
    if @mapped_fields
      if session[:map_fields][:file]
        File.delete(session[:map_fields][:file])
      end
      session[:map_fields] = nil
      @mapped_fields = nil
      @map_fields_error = nil
    end
  end

  module ClassMethods
    def map_fields(actions, fields, options = {})
      write_inheritable_attribute(:map_fields_fields, fields)
      write_inheritable_attribute(:map_fields_options, options)
      before_filter :map_fields, :only => actions
      after_filter :map_fields_cleanup, :only => actions
    end
  end

  class MappedFields
    attr_reader :mapping, :ignore_first_row, :file

    def initialize(file, fields, mapping, ignore_first_row)
      @file = file
      @fields = fields
      @mapping = {}
      @ignore_first_row = ignore_first_row == '1'

      mapping.each do |k,v|
        unless v.to_i == 0
          #Numeric mapping
          @mapping[v.to_i - 1] = k.to_i - 1
          #Text mapping
          @mapping[fields[v.to_i-1]] = k.to_i - 1
          #Symbol mapping
          sym_key = fields[v.to_i-1].downcase.
                                      gsub(/[-\s\/]+/, '_').
                                      gsub(/[^a-zA-Z0-9_]+/, '').
                                      to_sym
          @mapping[sym_key] = k.to_i - 1
        end
      end
    end

    def is_mapped?(field)
      !@mapping[field].nil?
    end

    def each
      row_number = 1
      FasterCSV.foreach(@file) do |csv_row|
        unless row_number == 1 && @ignore_first_row
          row = {}
          @mapping.each do |k,v|
            row[k] = csv_row[v]
          end
          row.class.send(:define_method, :number) { row_number }
          yield(row)
        end
        row_number += 1
      end
    end
  end

  class InconsistentStateError < StandardError
  end

  class MissingFileContentsError < StandardError
  end

  class ParamsParser
    def self.parse(params, field = nil)
      result = []
      params.each do |key,value|
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
        result << ["", value]
      end
      result.each do |arr|
        yield arr[0], arr[1]
      end
    end
  end
end

if defined?(Rails) and defined?(ActionController)
  ActionController::Base.send(:include, MapFields)
  ActionController::Base.view_paths.push File.expand_path(File.join(File.dirname(__FILE__), '..', 'views'))
  #This is a hack but the above code is not enough when using bundler and Rails 2.3.5
  ActionController::Base.view_paths.push "app/views"
end
