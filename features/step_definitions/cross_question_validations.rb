Given /^I have the following cross question validations$/ do |table|
  table.hashes.each do |hash|
    question_question = hash.delete 'question'
    related_question_question = hash.delete 'related'
    question = Question.find_by_question! question_question
    related_question = Question.find_by_question! related_question_question
    validation = Factory(:cross_question_validation, hash.merge({question: question, related_question: related_question}))
  end
end