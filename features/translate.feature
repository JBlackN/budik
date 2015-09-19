Feature: Translation
  In order to have better experience when using the app
  As a person whose native language is not English
  I want an option to translate the app to my native language

  Scenario: Translation
    Given I have run the app with 'translate' command
    When I pass language code as an argument
    Then The language file will be created/opened
