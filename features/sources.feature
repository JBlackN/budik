Feature: Sources
  In order to have an easier way to view and manage my sources
  As an user with sometimes unreliable internet connection
  I want to be able to list and pre-download some or all of my sources

  Background:
    Given I have run the app with 'sources' command

  Scenario Outline: Listing sources
    When I pass <option>
    Then I receive nicely formatted list of my sources

    Examples:
      | option             |
      | list of categories |
      | nothing            |

  Scenario: Editing sources
    When I pass 'edit' option
    Then My sources file will be opened in default editor

  Scenario Outline: Downloading sources
    When I pass 'download' and <option>
    Then The app will download specified sources

    Examples:
      | option             |
      | list of categories |
      | nothing else       |
