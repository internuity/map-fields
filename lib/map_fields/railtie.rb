module MapFields
  class Railtie < Rails::Railtie
    AbstractController::Base.send(:include, MapFields::Controller)
  end
end
