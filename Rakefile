require 'rubygems'
require 'bundler/gem_tasks'
require 'coveralls/rake/task'
require 'cucumber'
require 'cucumber/rake/task'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = 'features --format pretty'
end
RSpec::Core::RakeTask.new(:spec)
Coveralls::RakeTask.new
RuboCop::RakeTask.new

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.md'
  rdoc.rdoc_files.include('README.md', 'lib/*.rb', 'lib/budik/*.rb')
  rdoc.rdoc_dir = 'doc'
end

task default: [:features, :spec, 'coveralls:push', :rubocop]
