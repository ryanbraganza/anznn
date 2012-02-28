Feature: Submit Response
  In order to mark my response as finished and remove it from my "in-progress" responses
  As a data provider
  I want to submit my response

  As a Data Provider Supervisor
  I want to submit responses with (non-fatal) warnings

  Background:
    Given I have the usual roles
    And I have a user "superuser@intersect.org.au" with role "Administrator"
    And I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "ABC Hospital"
    And I am logged in as "supervisor@intersect.org.au" and have role "Data Provider Supervisor" and I'm linked to hospital "ABC Hospital"
    And I have a survey with name "The Survey" and questions
      | section | question   | question_type | number_min | mandatory |
      | 1       | Text Qn    | Text          |            | true      |
      | 2       | Integer Qn | Integer       | 4          | true      |

    Given I am logged in as "data.provider@intersect.org.au"
    And I create a response for "The Survey" with baby code "baby_not_started"
    And I create a response for "The Survey" with baby code "baby_range_warnings"
    And I create a response for "The Survey" with baby code "baby_incomplete"
    And I create a response for "The Survey" with baby code "baby_complete"

    Given I am on the response page for baby_range_warnings
    And I answer "Text Qn" with "something"
    And I press "Save and go to next section"
    And I answer "Integer Qn" with "3"
    And I press "Save"

    Given I am on the response page for baby_incomplete
    And I answer "Text Qn" with "something"
    And I press "Save"

    Given I am on the response page for baby_complete
    And I answer "Text Qn" with "something"
    And I press "Save and go to next section"
    And I answer "Integer Qn" with "4"
    And I press "Save"

  Scenario Outline: submitting surveys from the home page without warnings
    Given I am logged in as "<user>@intersect.org.au"
    When I am on the home page
    Then I should see a submit button on the home page for survey "The Survey" and baby code "<baby_code>"
    When I submit the survey for survey "The Survey" and baby code "<baby_code>"
    Then I should be on the home page
    And I should see a confirmation message that "<baby_code>" for survey "The Survey" has been submitted
    And I should not see the response for survey "The Survey" and baby code "<baby_code>" on the home page
    And I can't view response for survey "The Survey" and baby code "<baby_code>"
    And I can't edit response for survey "The Survey" and baby code "<baby_code>"
    And I can't review response for survey "The Survey" and baby code "<baby_code>"
  Examples:
    | user          | baby_code     |
    | data.provider | baby_complete |
    | supervisor    | baby_complete |

  Scenario Outline: submitting surveys from the response summary page without warnings
    Given I am logged in as "<user>@intersect.org.au"
    When I am on the response summary page for <baby_code>
    Then I should see a submit button on the response summary page for survey "The Survey" and baby code "<baby_code>"
    When I submit the survey for survey "The Survey" and baby code "<baby_code>"
    Then I should be on the home page
    And I should see a confirmation message that "<baby_code>" for survey "The Survey" has been submitted
    And I should not see the response for survey "The Survey" and baby code "<baby_code>" on the home page
    And I can't view response for survey "The Survey" and baby code "<baby_code>"
    And I can't edit response for survey "The Survey" and baby code "<baby_code>"
    And I can't review response for survey "The Survey" and baby code "<baby_code>"
  Examples:
    | user          | baby_code     |
    | data.provider | baby_complete |
    | supervisor    | baby_complete |

  Scenario: Submiting survey with range warnings by Supervisor from home page
    Given I am logged in as "supervisor@intersect.org.au"
    When I am on the home page
    Then I should see a submit button on the home page for survey "The Survey" and baby code "baby_range_warnings" with no warning
    When I submit the survey for survey "The Survey" and baby code "baby_range_warnings"
    Then I should be on the home page
    And I should see a confirmation message that "baby_range_warnings" for survey "The Survey" has been submitted
    And I should not see the response for survey "The Survey" and baby code "baby_range_warnings" on the home page
    And I can't view response for survey "The Survey" and baby code "baby_range_warnings"
    And I can't edit response for survey "The Survey" and baby code "baby_range_warnings"
    And I can't review response for survey "The Survey" and baby code "baby_range_warnings"

  Scenario: Submiting survey with range warnings by Supervisor from response summary page
    Given I am logged in as "supervisor@intersect.org.au"
    When I am on the response summary page for baby_range_warnings
    Then I should see a submit button on the home page for survey "The Survey" and baby code "baby_range_warnings" with no warning
    When I submit the survey for survey "The Survey" and baby code "baby_range_warnings"
    Then I should be on the home page
    And I should see a confirmation message that "baby_range_warnings" for survey "The Survey" has been submitted
    And I should not see the response for survey "The Survey" and baby code "baby_range_warnings" on the home page
    And I can't view response for survey "The Survey" and baby code "baby_range_warnings"
    And I can't edit response for survey "The Survey" and baby code "baby_range_warnings"
    And I can't review response for survey "The Survey" and baby code "baby_range_warnings"

  Scenario Outline: can't submit with warnings
    Given I am logged in as "<user>@intersect.org.au"
    When I am on the home page
    Then I should not see a submit button on the home page for survey "The Survey" and baby code "<baby_code>" with warning "<warning>"
    When I am on the response summary page for <baby_code>
    Then I should not see a submit button on the response summary page for survey "The Survey" and baby code "<baby_code>" with warning "<warning>"
  Examples:
    | user          | baby_code           | warning                                                                                              |
    | supervisor    | baby_incomplete     | This survey is incomplete and can't be submitted.                                                    |
    | data.provider | baby_incomplete     | This survey is incomplete and can't be submitted.                                                    |
    | data.provider | baby_range_warnings | This survey has warnings. Double check them. If you believe them to be correct, contact a supervisor.|

  Scenario Outline: can't submit without warnings
    Given I am logged in as "<user>@intersect.org.au"
    When I am on the home page
    Then I should not see a submit button on the home page for survey "The Survey" and baby code "<baby_code>" with no warning
    When I am on the response summary page for <baby_code>
    Then I should not see a submit button on the response summary page for survey "The Survey" and baby code "<baby_code>" with no warning
  Examples:
    | user          | baby_code           |
    | supervisor    | baby_not_started    |
    | data.provider | baby_not_started    |
    | superuser     | baby_not_started    |
    | superuser     | baby_range_warnings |
    | superuser     | baby_incomplete     |
    | superuser     | baby_complete       |
