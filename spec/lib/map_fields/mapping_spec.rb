require 'map_fields/mapping'
require 'active_support/all'

module MapFields
  describe Mapping do
    let(:fields) { ['Field 1', 'Field 2', 'Field 3'] }
    let(:mapping) { Mapping.new({'2' => '0', '0' => '1', '1' => '2'}, fields) }

    it "indexes by field name" do
      mapping['Field 1'].should == 2
    end

    it "indexes by symbol" do
      mapping[:field_2].should == 0
    end

    it "indexes by mapped index" do
      mapping[2].should == 1
    end

    it "tells if a field has been mapped" do
      mapping.is_mapped?(:field_1).should be_true
    end

    it "tells if a field has not been mapped" do
      mapping.is_mapped?(:field_4).should be_false
    end

    it "knows the mapping for a specified column" do
      mapping.selected_mapping(0).should == 1
    end
  end
end
