require 'rubygems'
require "bundler/gem_tasks"
require 'coveralls/rake/task'
require 'cucumber'
require 'cucumber/rake/task'
require "rspec/core/rake_task"
require 'rubocop/rake_task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end
RSpec::Core::RakeTask.new(:spec)
Coveralls::RakeTask.new
RuboCop::RakeTask.new

task :default => :spec
