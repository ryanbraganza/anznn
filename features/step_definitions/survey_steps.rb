Given /^I have a simple survey$/ do
  create_simple_survey
end

Given /^I have a survey with name "([^"]*)" and questions$/ do |name, table|
  survey = Survey.create!(:name => name)
  create_questions(survey, table)
end

Given /^I have a survey with name "([^"]*)"$/ do |name|
  Survey.create!(:name => name)
end

Given /^"([^"]*)" has sections$/ do |survey_name, table|
  survey = Survey.find_by_name(survey_name)
  table.hashes.each do |sec_attrs|
    Factory(:section, sec_attrs.merge(survey: survey))
  end
end

Given /^"([^"]*)" has questions$/ do |survey_name, table|
  survey = Survey.find_by_name(survey_name)
  create_questions(survey, table)
end

Given /^"(.*)" created a response to a simple survey$/ do |email|
  create_response($simple_survey, email)
end

Given /^"([^"]*)" created a response to the "([^"]*)" survey$/ do |email, survey_name|
  create_response(Survey.find_by_name(survey_name), email)
end

def create_simple_survey
  survey = Survey.create!(name: 'simple')
  section = Section.create!(survey: survey, order: 1, name: 'Section1')
  q = Question.create!(question: 'What is the answer?', section: section, order: 1, question_type: "Text", code: "What", data_domain: "")
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

When /^I answer "([^"]*)" with "([^"]*)"$/ do |q, a|
  question = Question.find_by_question(q)
  fill_in "question_#{question.id}", :with => a
end

Then /^I should see help text "([^"]*)" for question "([^"]*)"$/ do |text, question_label|
  question = question_div(question_label)

  classes = question[:class].split(" ")
  classes.include?("warning").should be_false

  help_text = question.find(".help-block")
  help_text.text.gsub("\n", "").should eq(text)
end

Then /^I should see warning "([^"]*)" for question "([^"]*)"$/ do |warning, question_label|
  question = question_div(question_label)

  classes = question[:class].split(" ")
  classes.include?("warning").should be_true, "Expected question div to have class=warning, but found only #{classes}"

  warning_text = question.find(".help-block")
  warning_text.text.gsub("\n", "").should eq(warning)
end

Then /^I should see no warnings$/ do
  page.should_not have_css(".warning")
end

Then /^"([^"]*)" should have no warning$/ do |question_label|
  question = question_div(question_label)

  classes = question[:class].split(" ")
  classes.include?("warning").should be_false
end

When /^I create a response for "([^"]*)" with baby code "([^"]*)"$/ do |survey, baby_code|
  visit path_to("the new response page")
  fill_in "Baby code", :with => baby_code
  select survey, :from => "Survey"
  click_button "Save"
end

def question_div(question_label)
  question = Question.find_by_question(question_label)
  find("#container_#{question.id}")
end

Given /^I answer as follows$/ do |table|
  questions_to_answer_values = table_to_questions_and_answers(table)
  questions_to_answer_values.each do |question, answer_value|
    case question.question_type
      when 'Choice'
        within(question_div(question.question)) { choose(answer_value) }
      when 'Date'
        y, m, d = answer_value.split '/'
        select y, from: "answers_#{question.id}_year"
        select m, from: "answers_#{question.id}_month"
        select d, from: "answers_#{question.id}_day"
      else
        fill_in "question_#{question.id}", with: answer_value.to_s
     # TODO support more question types
    end

  end
end

Then /^I should see the following answers$/ do |table|
  questions_to_answer_values = table_to_questions_and_answers(table)
  questions_to_answer_values.each do |question, answer_value|
    case question.question_type
      when 'Choice', 'Decimal', 'Integer'
        field = find_field("question_#{question.id}")
        field_value = field.value
      when 'Date'
        y = find("#answers_#{question.id}_year").value
        m = find("#answers_#{question.id}_month").value
        d = find("#answers_#{question.id}_day").value
        field_value = "#{y}/#{m}/#{d}"
      else
        raise "Not Implemented"
    end
    field_value.should eq answer_value.to_s
  end
end

def table_to_questions_and_answers(table)
  table.hashes.reduce([]) do |arr, row|
    question_question = row[:question]
    answer_value = row[:answer]
    question = Question.find_by_question!(question_question)
    case question.question_type
      when 'Text', 'Choice', 'Date'
        'no op'
      when 'Time'
        raise 'not implemented'
      when 'Decimal'
        answer_value = answer_value.to_f
      when 'Integer'
        answer_value = answer_value.to_i
      else
        raise 'no such question type'
    end
    arr.push [question, answer_value]
    arr
  end
end

Given /^question "([^"]*)" has question options$/ do |question_name, table|
  question = Question.find_by_question(question_name)
  table.hashes.each do |qo_attrs|
    question.question_options.create!(qo_attrs)
  end
end

Then /^I should see choice question "([^"]*)" with options$/ do |question_name, table|
  question_div = question_div(question_name)

  labels = question_div.all("ul.inputs-list li label")
  options_on_page = []
  labels.each do |label_item|
    label_text = label_item.find("span.radio-label").text
    hint_text = label_item.find("span.help-block").text
    checked = label_item.has_selector?("input[type=radio]", :checked => true)
    options_on_page << {"label" => label_text, "hint" => hint_text, "checked" => checked.to_s}
  end
  options_on_page.should eq(table.hashes)
end

Then /^the answer to "([^"]*)" should be "([^"]*)"$/ do |question_name, expected_answer|
  question = Question.find_by_question!(question_name)
  response = Response.last
  answer = response.answers.find_by_question_id(question.id)
  raise "Didn't find any answer for question '#{question_name}'" unless answer
  case question.question_type
    when 'Text'
      answer.text_answer.should eq(expected_answer)
    when 'Date'
      raise 'Not implemented'
    when 'Time'
      raise 'Not implemented'
    when 'Choice'
      answer.choice_answer.should eq(expected_answer)
    when 'Decimal'
      raise 'Not implemented'
    when 'Integer'
      answer.integer_answer.should eq(expected_answer.to_i)
    else
      raise 'no such question type'
  end
end

Then /^I should see questions$/ do |table|
  expected = table.raw.collect { |r| r[0] }
  actual = all("form .clearfix label").collect { |element| element.text }
  actual.should eq(expected)
end

def create_questions(survey, table)
  table.hashes.each do |q_attrs|
    section_num = q_attrs.delete("section")
    section_num ||= 0
    section = survey.sections.find_by_order(section_num)
    section = Factory(:section, survey: survey, order: section_num) unless section
    Factory(:question, q_attrs.merge(section: section))
  end
end

When /^I focus on question "(.*)"$/ do |question_question|
  question = Question.find_by_question!(question_question)
  if question.type_choice?
    first_option = question.question_options.first
    focusable_selector = "#answers_#{question.id}_#{first_option.option_value}"
  elsif question.type_date?
    focusable_selector = "#answers_#{question.id}_day"
  elsif question.type_time?
    focusable_selector = "#answers_#{question.id}_hour"
  else
    focusable_selector = "#question_#{question.id}"
  end
  page.execute_script <<-endscript
    /*
     * FIXME: THIS IS A HACK
     * There are timing issues involved with when focus and blur are called.
     * We should only have to call focus once.
     */
    jQuery('#{focusable_selector}').focus().focus();
  endscript
end

Then /^I should see the sidebar help for "([^"]*)"$/ do |question_question|
  question = Question.find_by_question!(question_question)
  page.should have_content question.description
  page.should have_content question.guide_for_use
end

And /^I should not see the sidebar help for "(.*)"$/ do |question_question|
  question = Question.find_by_question!(question_question)
  page.should_not have_content question.description
  page.should_not have_content question.guide_for_use
end

When /^I hover on question label for "(.*)"$/ do |question_question|
  question = Question.find_by_question!(question_question)
  page.execute_script <<-endscript
    jQuery('#container_#{question.id}').find('label').mouseenter();
  endscript
end

Then /^I should see the help tooltip for "(.*)"$/ do |question_question|
  question = Question.find_by_question!(question_question)
  page.should have_content question.data_domain
end
