Given /^I have a simple survey$/ do
  create_simple_survey
end

Given /^I have a survey with name "([^"]*)" and questions$/ do |name, table|
  survey = Survey.create!(:name => name)
  section = Section.create!(survey: survey, order: 1)
  table.hashes.each do |q_attrs|
    Factory(:question, q_attrs.merge(section: section))
  end
end

Given /^"(.*)" created a response to a simple survey$/ do | email |
  create_response($simple_survey, email)
end

Given /^"([^"]*)" created a response to the "([^"]*)" survey$/ do |email, survey_name|
  create_response(Survey.find_by_name(survey_name), email)
end

def create_simple_survey
  survey = Survey.create!(name: 'simple')
  section = Section.create!(survey: survey, order: 1)
  q = Question.create!(question: 'What is the answer?', section: section, order: 1, question_type: "Text", code: "What")
  $simple_survey = survey
end

def simple_question
  $simple_survey.sections.first.questions.first
end

def create_response(survey, email)
  user = User.find_by_email(email)
  Response.create!(survey: survey, baby_code: 'babycode123', user: user)
end

Then /^I should see the simple questions$/ do
  page.should have_content simple_question.question
end

When /^I answer the simple questions$/ do
  fill_in "question_#{simple_question.id}", :with => 'something'
end

Then /^I should see the simple questions with my previous answers$/ do
  question_field = find_field("question_#{simple_question.id}")
  question_field.value.should eq "something"
end

Then /^I should see help text "([^"]*)" for question "([^"]*)"$/ do |text, question_label|
  question = Question.find_by_question(question_label)
  containing_div = find("#container_#{question.id}")
  help_text = containing_div.find(".help-block")
  help_text.should have_content(text)
end
