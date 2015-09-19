Feature: Config
  In order to save time
  As a busy person
  I want an option to edit and reset configuration directly from the app.

  Background:
    Given I have run the app with command 'config'

  Scenario: Edit app configuration
    When I pass no options
    Then the configuration file should be opened in default editor

  Scenario: Reset app configuration
    When I pass 'reset'
    Then the configuration file should be reset to defaults
