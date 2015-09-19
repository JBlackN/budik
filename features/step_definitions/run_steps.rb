# Feature: Run

Given(/^I have run the app$/) do
  platform = Budik::Config.instance.platform?
  @options = './config/templates/options/' + platform.to_s + '.yml'
  @sources = './config/templates/sources/sources.yml'
  Budik::Config.instance.options = YAML.load_file(@options)
  Budik::Config.instance.sources = YAML.load_file(@sources)

  R18n.default_places = './config/templates/lang/'
  R18n.set('en')
  Budik::Config.instance.lang = R18n.t

  @opts = double
  allow(@opts).to receive_messages(
    player: nil,
    rng: nil,
    dl_method: nil,
    categories: nil,
    number: nil
  )
end

# Scenario: Everything runs as expected

Then(/^The app wakes me up with one of my favorite songs or videos$/) do
  expect_any_instance_of(Budik::Command).to receive(:puts)
  expect(Budik::Player.instance).to receive(:play)
  expect(Budik::Storage.instance).to receive(:remove_sources)
  expect_any_instance_of(Budik::Command).to receive(:run_play) do
    source = double
    Budik::Devices.instance.tv_on
    Budik::Player.instance.play(source)
    Budik::Devices.instance.tv_off
    Budik::Storage.instance.remove_sources(source)
    Budik::Devices.instance.storage_unmount
    Budik::Devices.instance.storage_sleep
  end
  expect_any_instance_of(Budik::Command).not_to receive(:run_alarm_fallback)
  Budik::Command.new(:run, @opts)
end

# Scenario: Something bad happens

When(/^My 'sources' file has invalid syntax$/) do
  Budik::Config.instance.sources = YAML.load('item')

  err = 'Invalid sources format'
  expect(Budik::Sources.instance).to receive(:parse).and_raise(err)
  expect_any_instance_of(Budik::Command).to receive(:run_alarm_fallback)
  Budik::Command.new(:run, @opts)

  Budik::Config.instance.sources = @sources
end

When(/^Player ran but didn't play anything$/) do
  expect_any_instance_of(Budik::Command).to receive(:puts)
  expect(Budik::Player.instance).to receive(:play)
  expect_any_instance_of(Budik::Command).to receive(:run_alarm_fallback)
  Budik::Command.new(:run, @opts)
end

When(/^Another exception is encountered$/) do
  expect_any_instance_of(Budik::Command).to receive(:run_alarm) { fail }
  expect_any_instance_of(Budik::Command).to receive(:run_alarm_fallback)
  Budik::Command.new(:run, @opts)
end

Then(/^The app still wakes me up \(unless the speakers are off\)$/) {}
