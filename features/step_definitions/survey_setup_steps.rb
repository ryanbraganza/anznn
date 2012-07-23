include CsvSurveyOperations

Given /^I have a survey with name "([^"]*)" and questions$/ do |name, table|
  survey = Survey.create!(:name => name)
  create_questions(survey, table)
  setup_year_of_reg("2001", "2012")
  refresh_static_cache
end

Given /^I have a survey with name "([^"]*)"$/ do |name|
  Survey.create!(:name => name)
  setup_year_of_reg("2001", "2012")
  refresh_static_cache
end

And /^I have a survey with name "(.*)" with questions from "(.*)" and options from "(.*)"$/ do |survey_name, question_filename, options_filename|
  pathify = ->(path) { Rails.root.join('test_data', path) }
  questions_path = pathify[question_filename]
  options_path = pathify[options_filename]
  create_survey(survey_name, questions_path, options_path)
  refresh_static_cache
end

Given /^"([^"]*)" has sections$/ do |survey_name, table|
  survey = Survey.find_by_name(survey_name)
  table.hashes.each do |sec_attrs|
    Factory(:section, sec_attrs.merge(survey: survey))
  end
  refresh_static_cache
end

Given /^"([^"]*)" has questions$/ do |survey_name, table|
  survey = Survey.find_by_name(survey_name)
  create_questions(survey, table)
  refresh_static_cache
end

Given /^question "([^"]*)" has question options$/ do |question_name, table|
  question = Question.find_by_question(question_name)
  question.question_options.delete_all
  table.hashes.each do |qo_attrs|
    Factory(:question_option, qo_attrs.merge(question: question))
  end
  refresh_static_cache
end

Given /^I have the standard survey setup$/ do
  question_file = Rails.root.join 'test_data/survey', 'survey_questions.csv'
  options_file = Rails.root.join 'test_data/survey', 'survey_options.csv'
  cross_question_validations_file = Rails.root.join 'test_data/survey', 'cross_question_validations.csv'
  create_survey("MySurvey", question_file, options_file, cross_question_validations_file)
  setup_year_of_reg("2001", "2012")
  refresh_static_cache
end

Given /^I have year of registration range configured as "([^"]*)" to "([^"]*)"$/ do |from, to|
  ConfigurationItem.delete_all
  setup_year_of_reg(from, to)
end

# in production, surveys are never changed while the server is running, but are loaded once in an initializer
# here we need to refresh this cache as we've created surveys after the initializer has run
def refresh_static_cache
  StaticModelPreloader.load
end

def setup_year_of_reg(from, to)
  if ConfigurationItem.all.empty?
    Factory(:configuration_item, name: ConfigurationItem::YEAR_OF_REGISTRATION_START, configuration_value: from)
    Factory(:configuration_item, name: ConfigurationItem::YEAR_OF_REGISTRATION_END, configuration_value: to)
  end
end

def create_questions(survey, table)
  table.hashes.each do |q_attrs|
    section_num = q_attrs.delete("section")
    section_num ||= 0
    section = survey.sections.find_by_section_order(section_num)
    section = Factory(:section, survey: survey, section_order: section_num) unless section
    question = Factory(:question, q_attrs.merge(section: section, code: q_attrs['question']))
    if question.type_choice?
      Factory(:question_option, question: question, label: "Apple", option_value: "A")
      Factory(:question_option, question: question, label: "Bike", option_value: "B")
      Factory(:question_option, question: question, label: "Cat", option_value: "C")
    end
  end
end

