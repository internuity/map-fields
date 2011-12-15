require 'map_fields/mapping'

module MapFields
  describe Mapping do
    let(:fields) { ['Field 1', 'Field 2', 'Field 3'] }
    let(:mapping) { Mapping.new({'0' => '2', '1' => '0', '2' => '1'}, fields) }

    it "indexes by field name" do
      mapping['Field 1'].should == 2
    end

    it "indexes by symbol" do
      mapping[:field_2].should == 0
    end

    it "indexes by mapped index" do
      mapping[2].should == 1
    end
  end
end
