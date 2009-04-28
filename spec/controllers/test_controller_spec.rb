require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TestController do

  context "on upload" do
    context "with an attached file" do
      before do
        test_file  = ActionController::TestUploadedFile.new(File.join(File.dirname(__FILE__), '..', 'test-file.csv'))

        File.should_receive(:open) do |path, flags| 
          path.should match(Regexp.new(Dir::tmpdir))
          flags.should == 'wb'
        end
        FasterCSV.should_receive(:foreach)

        post :create, :file => test_file, :user => {:first_name => 'Test', :last_name => 'User'}
      end

      it "should assign to @fields" do
        assigns[:fields].should_not be_blank
      end

      it "should store the file location in the session" do
        session[:map_fields][:file].should_not be_blank
      end

      it "should assign to @parameters" do 
        assigns[:parameters].should_not be_blank
      end

      it "should have the first name parameter" do
        assigns[:parameters].should include(['user[first_name]', 'Test'])
      end

      it "should have the last name parameters" do
        assigns[:parameters].should include(['user[last_name]', 'User'])
      end
    end

    context "without an attached file" do
      it "should raise an error" do
        lambda { post :create }.should raise_error
      end
    end
  end

  context "on second post" do
    it "should map the fields" do
      session[:map_fields] = {:file => '/tmp/test'}
      FasterCSV.expects(:foreach)
      File.expects(:delete).with('/tmp/test')

      post :create, :fields => {"1" => "2", "2" => "3", "3" => "1"}
    end
  end
end
