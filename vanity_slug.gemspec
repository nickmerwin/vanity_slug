# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vanity_slug/version'

Gem::Specification.new do |gem|
  gem.name          = "vanity_slug"
  gem.version       = VanitySlug::VERSION
  gem.authors       = ["Nick Merwin"]
  gem.email         = ["nick@lemurheavy.com"]
  gem.description   = %q{root level Vanity Slug for any model}
  gem.summary       = %q{easily add vanity slugs}
  gem.homepage      = "https://github.com/nickmerwin/vanity_slug"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
