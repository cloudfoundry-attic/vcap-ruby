
$:.unshift File.expand_path("../lib", __FILE__)

require 'cfautoconfig/version'

spec = Gem::Specification.new do |s|
  s.name = "cf-autoconfig"
  s.version = AutoReconfiguration::VERSION
  s.author = "VMware"
  s.email = "support@vmware.com"
  s.homepage = "http://vmware.com"
  s.description = s.summary = "Cloud Foundry auto-reconfiguration for Ruby"

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["LICENSE"]

  s.add_dependency "cf-runtime"

  s.add_development_dependency "redis",     "~> 2.0"
  s.add_development_dependency "amqp",      "~> 0.8"
  s.add_development_dependency "carrot",    "~> 1.0"
  s.add_development_dependency "pg",        "~> 0.11.0"
  s.add_development_dependency "rake",      "~> 0.9.2"
  s.add_development_dependency "rcov",      "~> 0.9.10"
  s.add_development_dependency "rspec",     "~> 2.6.0"
  s.add_development_dependency "ci_reporter", "~> 1.6.5"

  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("{lib}/**/*")
end
