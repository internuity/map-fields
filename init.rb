ActionController::Base.send(:include, MapFields)
ActionController::Base.view_paths.push File.expand_path(File.join(File.dirname(__FILE__), 'views'))
