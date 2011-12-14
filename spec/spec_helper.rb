ENV['RAILS_ENV'] = 'test'

require 'bundler'
require File.expand_path('../../rails_app/config/environment.rb', __FILE__)
require 'rails/test_help'
require 'rspec/rails'

RailsApp::Application.routes.draw do
  resources :test
end
