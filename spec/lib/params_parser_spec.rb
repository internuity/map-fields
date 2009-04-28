require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MapFields::ParamsParser do
  context "with no specific field specified" do
    it "should be able to parse params[:id] = '1'" do
      params = {:id => '1'}

      MapFields::ParamsParser.parse(params).should == [["id", "1"]]
    end

    it "should be able to parse params[:user][:id] = '1'" do
      params = {:user => {:id => '1'}}

      MapFields::ParamsParser.parse(params).should == [["user[id]", "1"]]
    end

    it "should be able to parse params[:user][] = '1'" do
      params = {:user => ['1']}

      MapFields::ParamsParser.parse(params).should == [["user[]", "1"]]
    end

    it "should be able to parse params[:user][] = '1' with multiple entries" do
      params = {:user => ['1', '2', '3']}

      MapFields::ParamsParser.parse(params).size.should == 3
      MapFields::ParamsParser.parse(params)[0].should == ["user[]", "1"]
      MapFields::ParamsParser.parse(params)[1].should == ["user[]", "2"]
      MapFields::ParamsParser.parse(params)[2].should == ["user[]", "3"]
    end

    it "should be able to parse params[:user][:sub][:id] = '1'" do
      params = {:user => {:sub => {:id => '1'}}}

      MapFields::ParamsParser.parse(params).should == [["user[sub][id]", "1"]]
    end

    it "should be able to parse params[:user][:sub][] = '1'" do
      params = {:user => {:sub => ['1']}}

      MapFields::ParamsParser.parse(params).should == [["user[sub][]", "1"]]
    end

    it "should be able to parse params[:user][:sub][] = '1' with multiple entries" do
      params = {:user => {:sub => ['1', '2', '3']}}

      MapFields::ParamsParser.parse(params).size.should == 3
      MapFields::ParamsParser.parse(params)[0].should == ["user[sub][]", "1"]
      MapFields::ParamsParser.parse(params)[1].should == ["user[sub][]", "2"]
      MapFields::ParamsParser.parse(params)[2].should == ["user[sub][]", "3"]
    end

    it "should be able to parse params[:user][:sub][:sub2][] = '1'" do
      params = {:user => {:sub => {:sub2 => ['1']}}}

      MapFields::ParamsParser.parse(params).should == [["user[sub][sub2][]", "1"]]
    end

    it "should be able to parse a complicated collection of parameters" do
      params = {:user => {:sub => {:sub2 => ['1']}},
                :test => '1',
                :other => ['collection', 'of', 'parameters'],
                :checking => {:if => ['it', 'can'],
                              :handle => '1',
                              :big => {:bunch => {:of => {:rubish => ['thrown', 'at'],
                                                          :it => 'yes'}}}
                             }
               }

      MapFields::ParamsParser.parse(params).should include(["user[sub][sub2][]", "1"])
      MapFields::ParamsParser.parse(params).should include(["test", "1"])
      MapFields::ParamsParser.parse(params).should include(["other[]", "collection"])
      MapFields::ParamsParser.parse(params).should include(["other[]", "of"])
      MapFields::ParamsParser.parse(params).should include(["other[]", "parameters"])
      MapFields::ParamsParser.parse(params).should include(["checking[if][]", "it"])
      MapFields::ParamsParser.parse(params).should include(["checking[if][]", "can"])
      MapFields::ParamsParser.parse(params).should include(["checking[handle]", "1"])
      MapFields::ParamsParser.parse(params).should include(["checking[big][bunch][of][rubish][]", "thrown"])
      MapFields::ParamsParser.parse(params).should include(["checking[big][bunch][of][rubish][]", "at"])
      MapFields::ParamsParser.parse(params).should include(["checking[big][bunch][of][it]", "yes"])
    end
  end

  context "with a specified parameter" do
    it "should be able to get only the requested field" do
      params = {:user => {:sub => {:sub2 => ['1']}},
                :test => ['another', 'parameter']
               }

      MapFields::ParamsParser.parse(params, :user).should == [["user[sub][sub2][]", "1"]]
    end

    it "should be able to parse params[:user][:sub][:sub2][] = '1'" do
      params = {:user => {:sub => {:sub2 => ['1']}}}

      MapFields::ParamsParser.parse(params, :user).should == [["user[sub][sub2][]", "1"]]
    end
  end
end
