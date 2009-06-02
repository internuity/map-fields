RAILS_ROOT = File.join(File.dirname(__FILE__), 'rails_root')
RAILS_ENV = 'test'

#Needed for autospec
$LOAD_PATH << "spec"
$LOAD_PATH << "lib"

require 'rubygems'
#Needed for rspec_rails
require 'rails/version'
require 'action_controller'
require 'action_controller/test_process'
require 'spec/rails'
require File.join(File.dirname(__FILE__), '..', 'lib', 'map_fields')

require File.join(File.dirname(__FILE__), '..', 'init')

Spec::Runner.configure do |config|
  #config.use_transactional_fixtures = true
end

class TestController < ApplicationController
  map_fields :create, ['Title', 'First name', 'Last name'], :params => [:user]

  def new
  end

  def create
    if fields_mapped?
      mapped_fields.each do |row|
        #deal with the data
        row[0] #=> will be Title
        row[1] #=> will be First name
        row[2] #=> will be Last name
      end
      render :text => ''
    else
      render 'map_fields/_map_fields'
    end
  end
end

ActionController::Routing::Routes.draw do |map|
  map.resources :test
end
