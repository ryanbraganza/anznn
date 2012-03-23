FactoryGirl.define do
  factory :cross_question_validation do
    association :question
    association :related_question, factory: :question
    error_message "err"
    self.send(:method_missing, :rule, "comparison")  # using "rule" directly calls a rake method
    operator '=='
  end
end
