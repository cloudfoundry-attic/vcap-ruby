# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cf-runtime/version"

Gem::Specification.new do |s|
  s.name        = "cf-runtime"
  s.version     = CFRuntime::VERSION
  s.author      = "VMware"
  s.email       = "support@vmware.com"
  s.homepage    = "http://vmware.com"
  s.description = s.summary = "Cloud Foundry Runtime Library"

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.rdoc_options = ["-N", "--tab-width=2", "--exclude='cf-runtime.gemspec|spec'"]

  s.add_development_dependency "redis",     "~> 2.0"
  s.add_development_dependency "dalli",     "~> 2.6.4"
  s.add_development_dependency "amqp",      "~> 0.8"
  s.add_development_dependency "carrot",    "~> 1.0"
  s.add_development_dependency "mongo",     "~> 1.2.0"
  s.add_development_dependency "pg",        "~> 0.11.0"
  s.add_development_dependency "mysql2",    "~> 0.2.7"
  s.add_development_dependency "aws-s3",    "~> 0.6.3"
  s.add_development_dependency "rake",      "~> 0.9.2"
  s.add_development_dependency "rack-test", "~> 0.6.1"
  s.add_development_dependency "rspec",     "~> 2.6.0"
  s.add_development_dependency "ci_reporter", "~> 1.6.5"
  s.add_development_dependency "simplecov", "~> 0.6.1"
  s.add_development_dependency "simplecov-rcov", "~> 0.2.3"

  s.require_path = 'lib'
  s.files = %w(LICENSE README.md) + Dir.glob("{lib}/**/*")
end
