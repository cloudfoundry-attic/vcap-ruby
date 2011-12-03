# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cfruntime/version"

Gem::Specification.new do |s|
  s.name        = "cf-runtime"
  s.version     = CFRuntime::VERSION
  s.author      = "VMware"
  s.email       = "support@vmware.com"
  s.homepage    = "http://vmware.com"
  s.description = s.summary = "Cloud Foundry Runtime Library"

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["LICENSE"]

  s.add_dependency "json_pure", "~> 1.6.1"

  s.add_development_dependency "rake",      "~> 0.9.2"
  s.add_development_dependency "rcov",      "~> 0.9.10"
  s.add_development_dependency "rack-test", "~> 0.6.1"
  s.add_development_dependency "rspec",     "~> 2.6.0"
  s.add_development_dependency "ci_reporter", "~> 1.6.5"

  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("{lib}/**/*")
end
