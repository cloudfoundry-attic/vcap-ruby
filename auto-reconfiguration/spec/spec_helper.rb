require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

$:.unshift('./lib')
require 'bundler'
require 'bundler/setup'
require 'rspec'