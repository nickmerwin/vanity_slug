require 'rubygems'
require 'bundler/setup'

require 'simplecov'
SimpleCov.start

require 'active_support/all'
require 'vanity_slug'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

def silence
  return yield if ENV['silence'] == 'false'
  
  silence_stream(STDOUT) do
    yield
  end
end
