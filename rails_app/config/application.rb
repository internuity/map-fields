require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'

Bundler.require

module RailsApp
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
  end
end
