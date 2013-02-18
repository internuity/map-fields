require 'map_fields/mapper'
require 'active_support/all'

module MapFields
  describe Mapper do
    let(:controller) { stub(:session => {}).as_null_object }
    let(:fields) { %w(one two three) }
    let(:file) { stub.as_null_object }

    context ".new" do
      it "accepts an array for the fields parameter" do
        mapper = Mapper.new(controller, fields, stub.as_null_object)
        mapper.fields.should == fields
      end

      it "accepts a symbol for the fields parameter that is the name of a controller method which should return an array" do
        controller.should_receive(:get_fields).and_return fields
        mapper = Mapper.new(controller, :get_fields, file)
        mapper.fields.should == fields
      end

      it "accepts a proc for the fields parameter which should return an array" do
        proc = ->{ fields }
        mapper = Mapper.new(controller, proc, file)
        mapper.fields.should == fields
      end

      it "writes a temporary file with the file contents" do
        file.should_receive(:read).and_return ''
        Mapper.new(controller, [], file)
      end

      it "stores the temporary file path in the session" do
        session = {}
        controller.should_receive(:session).and_return session
        Mapper.new(controller, [], file)
        session[:map_fields_file].should_not be_nil
      end

      it "reads in the first 10 rows of the file" do
        mapper = Mapper.new(controller, [], File.open('spec/files/test.csv'))
        mapper.rows.should have(10).rows
      end
    end

    context "#mapped?" do
      it "returns false if the file has been supplied" do
        mapper = Mapper.new(controller, [], file)
        mapper.should_not be_mapped
      end

      it "returns true if the file has not been supplied" do
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        mapper = Mapper.new(controller, [], nil)
        mapper.should be_mapped
      end
    end

    context "#error!" do
      it "reloads the file preview for cases when an error is detected within the controller and the mapping form should be shown again" do
        mapper = Mapper.new(controller, [], file)
        mapper.error!
        mapper.should_not be_mapped
      end
    end

    context "#is_mapped?" do
      it "returns false if no mapping has taken place" do
        mapper = Mapper.new(controller, [], file)
        mapper.is_mapped?(:field_1).should be_false
      end

      it "returns false if the field has not been mapped" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => '1', '3' => '0', '2' => '1', '0' => '2', '1' => '3'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.is_mapped?(:unkown).should be_false
      end

      it "returns true if the field has not been mapped" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => '1', '3' => '0', '2' => '1', '0' => '2', '1' => '3'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.is_mapped?(:email).should be_true
      end
    end

    context "#file" do
      let(:file) { File.expand_path('spec/files/test.csv') }

      before do
        controller.stub(:session => {map_fields_file: file, map_fields_file_name: 'test.csv'})
      end

      it "returns the file that was uploaded" do
        mapper = Mapper.new(controller, fields, nil)
        mapper.file.should be_a(UploadedFile)
      end

      it "includes the original file name" do
        mapper = Mapper.new(controller, fields, nil)
        mapper.file.original_filename.should == 'test.csv'
      end
    end

    context "mapping fields" do
      it "decorates the CSV reader to allow easy access to rows by field" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => '1', '3' => '0', '2' => '1', '0' => '2', '1' => '3'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.rows[0]['Title'].should == 'Mr'
      end

      it "supports the each syntax" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => true, '3' => '0', '2' => '1', '0' => '2', '1' => '3'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.each do |row|
          row[:title].should == 'Mr'
          break
        end
      end
    end
  end
end
