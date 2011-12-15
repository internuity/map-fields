require 'map_fields/mapper'

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

    context "mapping fields" do
      it "decorates the CSV reader to allow easy access to rows by field" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => true, '0' => '3', '1' => '2', '2' => '0', '3' => '1'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.rows[0]['Title'].should == 'Mr'
      end

      it "supports the each syntax" do
        fields = %w(Email Lastname Title Firstname)
        controller.stub(:session => {map_fields_file: File.expand_path('spec/files/test.csv')})
        controller.should_receive(:params).and_return(mapped_fields: {:ignore_first_row => true, '0' => '3', '1' => '2', '2' => '0', '3' => '1'})
        mapper = Mapper.new(controller, fields, nil)
        mapper.rows.each do |row|
          row[:title].should == 'Mr'
          break
        end
      end
    end
  end
end
