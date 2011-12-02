require File.join(File.dirname(__FILE__), '../','spec_helper')
require 'cfautoconfig/configuration_helper'

describe 'AutoReconfiguration::ConfigurationHelper' do

  it 'disables auto-config for single client with case-insensitivity' do
    ENV['DISABLE_AUTO_CONFIG'] = 'redis'
    (AutoReconfiguration::ConfigurationHelper::disabled? 'ReDiS').should == true
  end

  it 'disables auto-config for multiple clients with extra spaces using symbols' do
    ENV['DISABLE_AUTO_CONFIG'] = 'redis :  MongoDB'
    (AutoReconfiguration::ConfigurationHelper::disabled? :redis).should == true
    (AutoReconfiguration::ConfigurationHelper::disabled? :mongodb).should == true
    (AutoReconfiguration::ConfigurationHelper::disabled? :mysql).should == false
  end

  it 'disables auto-config for all clients if value set to ALL' do
    ENV['DISABLE_AUTO_CONFIG'] = 'All   :'
    val = (AutoReconfiguration::ConfigurationHelper::disabled? :redis)
    (AutoReconfiguration::ConfigurationHelper::disabled? :mongodb).should == true
    (AutoReconfiguration::ConfigurationHelper::disabled? :mysql).should == true
  end

end