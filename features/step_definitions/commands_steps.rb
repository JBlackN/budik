# Feature: Commands
# Scenario: Config

Given(/^I want to configure the app$/) {}
When(/^I pass command config$/) do
  expect_any_instance_of(Budik::Command).to receive(:config).with(nil)
  Budik::Command.new(:config, nil)
end

# Scenario: Run

Given(/^I want to run the app$/) {}
When(/^I pass command run$/) do
  expect_any_instance_of(Budik::Command).to receive(:run).with(nil)
  Budik::Command.new(:run, nil)
end

# Scenario: Sources

Given(/^I want to manage media sources$/) {}
When(/^I pass command sources$/) do
  expect_any_instance_of(Budik::Command).to receive(:sources).with(nil)
  Budik::Command.new(:sources, nil)
end

# Scenario: Translate

Given(/^I want to translate the app$/) {}
When(/^I pass command translate$/) do
  expect_any_instance_of(Budik::Command).to receive(:translate).with(nil)
  Budik::Command.new(:translate, nil)
end

Then(/^I should get access to correct functionality$/) {}
