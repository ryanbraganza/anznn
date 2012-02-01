Factory.define :cross_question_validation do |f|
  f.association :question
  f.association :related_question, factory: :question
  f.error_message "err"
  f.rule 'date_lte'
end
