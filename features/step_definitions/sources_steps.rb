# Feature: Sources

Given(/^I have run the app with 'sources' command$/) {}

# Scenario: Listing sources

When(/^I pass list of categories$/) do
  opts = double(categories: 'category', download: nil, edit: nil)
  mods = { adds: [['category']], rms: [] }
  expect(Budik::Sources.instance).to receive(:apply_mods).with(mods)
  expect(Budik::IO.instance).to receive(:sources_print)
  Budik::Command.new(:sources, opts)
end

When(/^I pass nothing$/) do
  opts = double(categories: nil, download: nil, edit: nil)
  expect(Budik::Sources.instance).not_to receive(:parse_mods)
  expect(Budik::Sources.instance).not_to receive(:apply_mods)
  expect(Budik::IO.instance).to receive(:sources_print)
  Budik::Command.new(:sources, opts)
end

Then(/^I receive nicely formatted list of my sources$/) {}

# Scenario: Editing sources

When(/^I pass 'edit' option$/) do
  opts = double(categories: nil, download: nil, edit: true)
  path = File.expand_path(Budik::Config.instance.options['sources']['path'])

  expect(Budik::Config.instance).to receive(:open_file).with(path)
  expect_any_instance_of(Budik::Command).not_to receive(:sources_list_dl)
  Budik::Command.new(:sources, opts)
end

Then(/^My sources file will be opened in default editor$/) {}

# Scenario: Downloading sources

When(/^I pass 'download' and list of categories$/) do
  opts = double(categories: 'category', download: true, edit: nil)
  mods = { adds: [['category']], rms: [] }
  expect(Budik::Sources.instance).to receive(:apply_mods).with(mods)
  expect(Budik::Storage.instance).to receive(:download_sources)
  Budik::Command.new(:sources, opts)
end

When(/^I pass 'download' and nothing else$/) do
  opts = double(categories: nil, download: true, edit: nil)
  expect(Budik::Sources.instance).not_to receive(:parse_mods)
  expect(Budik::Sources.instance).not_to receive(:apply_mods)
  expect(Budik::Storage.instance).to receive(:download_sources)
  Budik::Command.new(:sources, opts)
end

Then(/^The app will download specified sources$/) {}
