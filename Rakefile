require 'rubygems'
require "bundler/gem_tasks"
require 'coveralls/rake/task'
require 'cucumber'
require 'cucumber/rake/task'
require "rspec/core/rake_task"
require 'rubocop/rake_task'

Coveralls::RakeTask.new
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task :default => :spec
