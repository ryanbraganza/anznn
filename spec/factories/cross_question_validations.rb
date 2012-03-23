FactoryGirl.define do
  factory :cross_question_validation do
    association :question
    association :related_question, factory: :question
    error_message "err"
    rule 'comparison'
    operator '=='
  end
end
