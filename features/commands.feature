Feature: Commands
  In order to have easier control over the application
  As an user
  I want to split different functionalities into multiple commands

  Scenario Outline: Commands
    Given I want to <action>
    When I pass command <command>
    Then I should get access to correct functionality

    Examples:
      | action               | command   |
      | configure the app    | config    |
      | run the app          | run       |
      | manage media sources | sources   |
      | translate the app    | translate |
