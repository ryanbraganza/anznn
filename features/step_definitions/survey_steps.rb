Given /^I have a simple survey$/ do
  create_basic_survey
end

def create_basic_survey
  survey = Survey.create!
  section = Section.create!(survey: survey, order: 1)
  q = Question.create!(question: 'What is the answer?', section: section, order: 1, question_type: "Text", code: "What")
end
