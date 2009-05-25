require 'rubygems'
require 'test/unit'
gem 'rails', '2.3.2'
require 'active_support'
require 'active_support/test_case'
require 'active_record'

PLUGIN_ROOT = File.dirname(__FILE__) + '/../'
ActiveSupport::Dependencies.load_paths << File.join(PLUGIN_ROOT, 'lib')
require 'init'

require 'mocha'
