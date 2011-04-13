$LOAD_PATH << File.dirname(__FILE__) + '/lib'
require 'mass_assignment'

Gem::Specification.new do |s|
  s.name = 'mass_assignment'
  s.version = MassAssignment::VERSION
  s.authors = ['Lance Ivy']
  s.email = 'lance@cainlevy.net'
  s.homepage = 'http://github.com/cainlevy/mass_assignment'
  s.summary = 'Simple and secure params assignment for ActiveRecord'
  s.description = 'An alternative to attr_protected that supports a simpler, more secure params assignment mindset while also encouraging obviousness.'

  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.textile Rakefile rails/init.rb)
  s.test_files = Dir.glob("test/**/*")

  s.add_development_dependency('mocha')
end
