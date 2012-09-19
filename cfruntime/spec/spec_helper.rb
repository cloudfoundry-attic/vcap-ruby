require 'simplecov' if ENV['COVERAGE']
require File.expand_path('../support/service_spec_helpers', __FILE__)

RSpec.configure do |config|
  config.include ServiceSpecHelpers
end
