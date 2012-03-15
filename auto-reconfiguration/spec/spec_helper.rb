require 'simplecov' if ENV['COVERAGE']

$:.unshift('./lib')
require 'bundler'
require 'bundler/setup'
require 'rspec'