# Feature: Translation
# Scenario: Translation

Given(/^I have run the app with 'translate' command$/) {}

When(/^I pass language code as an argument$/) do
  expect(Budik::Config.instance).to receive(:translate).with('cz')
  Budik::Command.new(:translate, ['cz'])
end

Then(%r{^The language file will be created\/opened$}) {}
