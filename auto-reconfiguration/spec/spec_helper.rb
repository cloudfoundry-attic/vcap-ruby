if ENV['COVERAGE']
  require 'simplecov'
  if ENV['COVERAGE'] =~ /rcov/
    require 'simplecov-rcov'
    SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  end
  SimpleCov.start
end

$:.unshift('./lib')
require 'bundler'
require 'bundler/setup'
require 'rspec'