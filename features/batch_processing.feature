Feature: Processing batch files
  In order to get feedback about my file
  As a data provider
  I want to the system to process my batch file

  Background:
    Given I am logged in as "data.provider@intersect.org.au" and have role "Data Provider" and I'm linked to hospital "RPA"
    And I have the standard survey setup

  Scenario Outline: Invalid files that get rejected before validation
    Given I upload batch file "<file>" for survey "MySurvey"
    And the system processes the latest upload
    When I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Survey Type | Num records | Status | Details   | Reports |
      | MySurvey    |             | Failed | <message> |         |
  Examples:
    | file                    | message                                                                                     |
    | not_csv.xls             | The file you uploaded was not a valid CSV file                                              |
    | invalid_csv.csv         | The file you uploaded was not a valid CSV file                                              |
    | no_baby_code_column.csv | The file you uploaded did not contain a BabyCode column                                     |
    | missing_baby_code.csv   | The file you uploaded is missing one or more baby codes. Each record must have a baby code. |
    | blank_rows.csv          | The file you uploaded is missing one or more baby codes. Each record must have a baby code. |
    | empty.csv               | The file you uploaded did not contain any data                                              |
    | headers_only.csv        | The file you uploaded did not contain any data                                              |
    | duplicate_baby_code.csv | The file you uploaded contained duplicate baby codes. Each baby code can only be used once. |

  Scenario: Valid file with no errors or warnings
    Given I upload batch file "no_errors_or_warnings.csv" for survey "MySurvey"
    And the system processes the latest upload
    When I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Survey Type | Num records | Status                 | Details                                   | Reports        |
      | MySurvey    | 3           | Processed Successfully | Your file has been processed successfully | Summary Report |

  Scenario Outline: Well formed files that get rejected for validation errors
    Given I upload batch file "<file>" for survey "MySurvey"
    And the system processes the latest upload
    When I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Survey Type | Num records | Status | Details                                                                               | Reports                       |
      | MySurvey    | 3           | Failed | The file you uploaded did not pass validation. Please review the reports for details. | Summary Report\nDetail Report |
  Examples:
    | file                              |
    | bad_date.csv                      |
    | bad_decimal.csv                   |
    | bad_integer.csv                   |
    | bad_time.csv                      |
    | cross_question_error.csv          |
    | incorrect_choice_answer_value.csv |
    | missing_mandatory_column.csv      |
    | missing_mandatory_fields.csv      |
    | a_range_of_problems.csv           |

  Scenario: File that gets rejected because a baby code already exists in the system
    Given "data.provider@intersect.org.au" created a response to the "MySurvey" survey with babycode "B2"
    And I upload batch file "no_errors_or_warnings.csv" for survey "MySurvey"
    And the system processes the latest upload
    When I am on the list of batch uploads page
    Then I should see "batch_uploads" table with
      | Survey Type | Num records | Status | Details                                                                               | Reports                       |
      | MySurvey    | 3           | Failed | The file you uploaded did not pass validation. Please review the reports for details. | Summary Report\nDetail Report |


