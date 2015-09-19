require 'coveralls'
Coveralls.wear_merged!
SimpleCov.merge_timeout 3600

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'budik'

RSpec.configure do |config|
  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, 'w')
    $stdout = File.open(File::NULL, 'w')
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
