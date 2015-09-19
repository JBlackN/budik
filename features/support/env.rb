require 'coveralls'
Coveralls.wear_merged!

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
require 'budik'
require 'cucumber/rspec/doubles'
