
$:.unshift File.expand_path("../lib", __FILE__)

require 'cf-autoconfig/version'

spec = Gem::Specification.new do |s|
  s.name = "cf-autoconfig"
  s.version = AutoReconfiguration::VERSION
  s.author = "VMware"
  s.email = "support@vmware.com"
  s.homepage = "http://vmware.com"
  s.description = s.summary = "Cloud Foundry auto-reconfiguration for Ruby"

  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ["LICENSE"]
  s.rdoc_options = ["-N", "--tab-width=2", "--exclude='cf-autoconfig.gemspec|spec'"]

  s.add_dependency "cf-runtime", "= 0.2.0"

  s.add_development_dependency "redis",     "~> 2.0"
  s.add_development_dependency "dalli",     "~> 2.6.4"
  s.add_development_dependency "amqp",      "~> 0.8"
  s.add_development_dependency "carrot",    "~> 1.0"
  s.add_development_dependency "mysql2",    "~> 0.2.7"
  s.add_development_dependency "pg",        "~> 0.11.0"
  s.add_development_dependency "mongo",     "~> 1.2.0"
  s.add_development_dependency "rake",      "~> 0.9.2"
  s.add_development_dependency "rspec",     "~> 2.6.0"
  s.add_development_dependency "ci_reporter", "~> 1.6.5"
  s.add_development_dependency "simplecov", "~> 0.6.1"
  s.add_development_dependency "simplecov-rcov", "~> 0.2.3"
  s.add_development_dependency "aws-s3",    "~> 0.6.3"

  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("{lib}/**/*")
end
