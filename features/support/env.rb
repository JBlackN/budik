$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'budik'
require 'coveralls'
require 'cucumber/rspec/doubles'

Coveralls.wear_merged!
SimpleCov.merge_timeout 3600
