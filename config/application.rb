require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module UexContactsBackend
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w(assets tasks))
    config.api_only = true

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore

    config.autoload_paths << Rails.root.join('app/services')
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '**/')]
  end
end
