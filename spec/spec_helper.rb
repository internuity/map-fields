ENV['RAILS_ENV'] = 'test'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'bundler'
require File.expand_path('../../rails_app/config/environment.rb', __FILE__)
require 'rails/test_help'
require 'rspec/rails'

require 'simplecov'
SimpleCov.start

require 'map_fields'

FileUtils.mkdir_p Rails.root.join('tmp')

RailsApp::Application.routes.draw do
  resources :test
end
