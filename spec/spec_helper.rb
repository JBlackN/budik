require 'coveralls'
Coveralls.wear_merged!
SimpleCov.merge_timeout 3600

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'budik'
