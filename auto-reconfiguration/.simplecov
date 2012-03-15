ENV['COVERAGE'] = 'true'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
end
