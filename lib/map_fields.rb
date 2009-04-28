require 'fastercsv'

module MapFields
  VERSION = '0.0.0'

  def self.included(base)
    base.extend(ClassMethods)
  end

  def map_fields
    default_options = {
      :file_field => 'file'
    }
    options = default_options.merge( 
                self.class.read_inheritable_attribute(:map_fields_options)
              )

    if session[:map_fields].nil? || params[options[:file_field]]
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

      @rows = []
      FasterCSV.foreach(temp_path) do |row|
        @rows << row
        break if @rows.size == 10
      end
      expected_fields = self.class.read_inheritable_attribute(:map_fields_fields)
      @fields = ([nil] + expected_fields).inject([]){ |o, e| o << [e, o.size]}
    else
      if session[:map_fields][:file].nil? || params[:fields].nil?
        session[:map_fields] = nil
        @map_fields_error =  InconsistentStateError
      else
        @mapped_fields = MappedFields.new(session[:map_fields][:file], 
                                          params[:fields])
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
    def map_fields(action, fields, options = {})
      write_inheritable_array(:map_fields_fields, fields)
      write_inheritable_attribute(:map_fields_options, options)
      before_filter :map_fields, :only => action
      after_filter :map_fields_cleanup, :only => action
    end
  end

  class MappedFields
    def initialize(file, mapping)
      @file = file
      @mapping = {}
      mapping.each do |k,v|
        @mapping[v.to_i - 1] = k.to_i - 1 unless v.to_i == 0
      end
    end

    def each
      FasterCSV.foreach(@file) do |csv_row|
        row = []
        @mapping.each do |k,v|
          row[k] = csv_row[v]
        end
        yield(row)
      end
    end
  end

  class InconsistentStateError < StandardError
  end

  class MissingFileContentsError < StandardError
  end
end
