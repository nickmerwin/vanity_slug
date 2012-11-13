require "active_support/all"

require "vanity_slug/version"
require "vanity_slug/active_record"

if defined?(Rails)
  require 'vanity_slug/vanity_router'
  require 'vanity_slug/railtie'
end

module VanitySlug
end
