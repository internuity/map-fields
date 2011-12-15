require 'map_fields/params_parser'

module MapFields
  describe ParamsParser do
    context "with no specific field specified" do
      it "ignores the controller and action" do
        params = {controller: 'test', action: 'index', id: '1'}

        ParamsParser.parse(params).should == [["id", "1"]]
      end

      it "ignores file fields" do
        params = {file: stub(read: ''), post: {title: 'Title', attachment: stub(read: '')}}

        ParamsParser.parse(params).should == [["post[title]", "Title"]]
      end

      it "parses params[id] = '1'" do
        params = {id: '1'}

        ParamsParser.parse(params).should == [["id", "1"]]
      end

      it "parses params[user][id] = '1'" do
        params = {user: {id: '1'}}

        ParamsParser.parse(params).should == [["user[id]", "1"]]
      end

      it "parses params[user][] = '1'" do
        params = {user: ['1']}

        ParamsParser.parse(params).should == [["user[]", "1"]]
      end

      it "parses params[user][] = '1' with multiple entries" do
        params = {user: ['1', '2', '3']}

        ParamsParser.parse(params).size.should == 3
        ParamsParser.parse(params)[0].should == ["user[]", "1"]
        ParamsParser.parse(params)[1].should == ["user[]", "2"]
        ParamsParser.parse(params)[2].should == ["user[]", "3"]
      end

      it "parses params[user][sub][id] = '1'" do
        params = {user: {sub: {id: '1'}}}

        ParamsParser.parse(params).should == [["user[sub][id]", "1"]]
      end

      it "parses params[user][sub][] = '1'" do
        params = {user: {sub: ['1']}}

        ParamsParser.parse(params).should == [["user[sub][]", "1"]]
      end

      it "parses params[user][sub][] = '1' with multiple entries" do
        params = {user: {sub: ['1', '2', '3']}}

        ParamsParser.parse(params).size.should == 3
        ParamsParser.parse(params)[0].should == ["user[sub][]", "1"]
        ParamsParser.parse(params)[1].should == ["user[sub][]", "2"]
        ParamsParser.parse(params)[2].should == ["user[sub][]", "3"]
      end

      it "parses params[user][sub][sub2][] = '1'" do
        params = {user: {sub: {sub2: ['1']}}}

        ParamsParser.parse(params).should == [["user[sub][sub2][]", "1"]]
      end

      it "parses a complicated collection of parameters" do
        params = {user:
          {
            sub: {
              sub2: ['1']
            }
          },
          test: '1',
          other: ['collection', 'of', 'parameters'],
          checking: {
            that: ['it', 'can'],
            handle: '1',
            big: {
              bunch: {
                of: {
                  rubish: ['thrown', 'at'],
                  it: 'yes'
                }
              }
            }
          }
        }

        ParamsParser.parse(params).should include(["user[sub][sub2][]", "1"])
        ParamsParser.parse(params).should include(["test", "1"])
        ParamsParser.parse(params).should include(["other[]", "collection"])
        ParamsParser.parse(params).should include(["other[]", "of"])
        ParamsParser.parse(params).should include(["other[]", "parameters"])
        ParamsParser.parse(params).should include(["checking[that][]", "it"])
        ParamsParser.parse(params).should include(["checking[that][]", "can"])
        ParamsParser.parse(params).should include(["checking[handle]", "1"])
        ParamsParser.parse(params).should include(["checking[big][bunch][of][rubish][]", "thrown"])
        ParamsParser.parse(params).should include(["checking[big][bunch][of][rubish][]", "at"])
        ParamsParser.parse(params).should include(["checking[big][bunch][of][it]", "yes"])
      end
    end

    context "with a specified parameter" do
      it "should be able to get only the requested field" do
        params = {user: {sub: {sub2: ['1']}},
          test: ['another', 'parameter']
        }

        ParamsParser.parse(params, :user).should == [["user[sub][sub2][]", "1"]]
      end

      it "parses params[user][sub][sub2][] = '1'" do
        params = {user: {sub: {sub2: ['1']}}}

        ParamsParser.parse(params, :user).should == [["user[sub][sub2][]", "1"]]
      end
    end
  end
end
