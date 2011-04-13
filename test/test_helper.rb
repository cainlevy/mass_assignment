require 'rubygems'
require 'test/unit'
gem 'rails', '3.0.6'
require 'active_support'
require 'active_support/test_case'
require 'active_record'

PLUGIN_ROOT = File.dirname(__FILE__) + '/../'
ActiveSupport::Dependencies.autoload_paths << File.join(PLUGIN_ROOT, 'lib')
require 'rails/init'

require 'mocha'
