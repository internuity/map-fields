require 'spec_helper'

class TestController < ActionController::Base
  append_view_path 'rails_app/app/views/'

  def create
    map_fields :get_fields, params[:file] do
      redirect_to action: :index
    end
  end

  private
  def get_fields
    [
      'Field #1',
      'Field #2',
      'Field #3'
    ]
  end
end

describe TestController, :type => :controller do
  render_views

  context "POST #create with uploaded file" do
    before do
      post :create, file: fixture_file_upload('spec/files/test.csv'), post: {title: 'Test Title', body: 'Test body'}
    end

    it "should respond with success" do
      response.status.should == 200
    end

    it 'assigns to rows' do
      assigns[:mapper].should be_a(MapFields::Mapper)
    end

    it "should render the create template" do
      response.should render_template('create')
    end

    it "should parse out the parameters" do
      mapper = assigns[:mapper]
      mapper.params.should == [['post[title]', 'Test Title'], ['post[body]', 'Test body']]
    end

    it "should render the map fields form" do
      response.body.should match(/id="map_fields_form"/)
    end
  end

  context "POST #create with mapped fields" do
    before do
      session[:map_fields_file] = File.expand_path('spec/files/test.csv')
      post :create, :mapped_fields => {'0' => '2', '1' => '1', '3' => '0'}
    end

    it "should respond with redirect" do
      response.status.should == 302
    end

    it "should redirect to the index action" do
      response.should redirect_to(action: :index)
    end
  end

  context "POST #create with mapped fields but a missing file" do
    it "should raise an error" do
      expect { post :create, :mapped_fields => {'0' => '2', '1' => '1', '3' => '0'} }.to raise_error(MapFields::MissingFileError)
    end
  end
end
