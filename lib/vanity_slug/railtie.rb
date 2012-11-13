module VanitySlug
  class Railtie < Rails::Railtie
    initializer "vanity_slug.configure_rails_initialization" do |app|
      app.middleware.use VanitySlug::VanityRouter
    end
  end
end
