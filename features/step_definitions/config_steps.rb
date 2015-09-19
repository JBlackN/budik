# Feature: Config

Given(/^I have run the app with command 'config'$/) do
  @opts = double
end

# Scenario: Edit app configuration

When(/^I pass no options$/) do
  allow(@opts).to receive(:reset).and_return(false)
end

Then(/^the configuration file should be opened in default editor$/) do
  expect(Budik::Config.instance).to receive(:edit)
  Budik::Command.new(:config, @opts)
end

# Scenario: Reset app configuration

When(/^I pass 'reset'$/) do
  allow(@opts).to receive(:reset).and_return(true)
end

Then(/^the configuration file should be reset to defaults$/) do
  expect(Budik::Config.instance).to receive(:reset)
  Budik::Command.new(:config, @opts)
end
