Feature: Run
  In order to wake up happy in the morning
  As an user
  I want the app to play music or YouTube video from my collection

  Background:
    Given I have run the app

  Scenario: Everything runs as expected
    Then The app wakes me up with one of my favorite songs or videos

  Scenario Outline: Something bad happens
    When <Exception>
    Then The app still wakes me up (unless the speakers are off)

    Examples:
      | Exception                            |
      | My 'sources' file has invalid syntax |
      | Player ran but didn't play anything  |
      | Another exception is encountered     |
