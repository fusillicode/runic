require File.expand_path('../boot', __FILE__)
require 'rails/all'

Bundler.require(*Rails.groups)

module Runic
  class Application < Rails::Application
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
      g.assets false
      g.helper false
      g.javascripts false
      g.stylesheets false
      g.template_engine false
      g.test_framework :rspec,
                       view_specs: false,
                       request_specs: false,
                       routing_specs: false
    end
  end
end
