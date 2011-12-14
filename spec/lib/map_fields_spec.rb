require 'spec_helper'

class TestController < ActionController::Base
  def create
    render :text => ''
  end
end

describe TestController, :type => :controller do
  context "POST #create" do
    before do
      post :create
    end

    it "should render nothing" do
      response.status.should == 200
    end
  end
end
