Given /^I have a simple survey$/ do
  create_simple_survey
end

Given /^"(.*)" created a response to a simple survey$/ do | email |
  user = User.find_by_email(email)
  Response.create!(survey: $simple_survey, baby_code: 'babycode123', user: user)
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
