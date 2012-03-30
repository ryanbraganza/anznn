FactoryGirl.define do
  factory :cross_question_validation do
    association :question
    association :related_question, factory: :question
    error_message "err"
    #We are using a sequence that doesn't sequence here because there is a name collision with Rake::DSL.rule
    sequence(:rule){'comparison'}
    operator '=='
    constant 0
    set_operator nil
    set nil
    conditional_operator nil
    conditional_constant nil
    conditional_set_operator nil
    conditional_set nil


    factory :cqv_comparison do
      sequence(:rule){'comparison'}
      operator '=='
    end

    factory :cqv_date_implies_constant do
      sequence(:rule){'date_implies_constant'}
      operator nil
      constant -1
    end
    factory :cqv_const_implies_const do
      sequence(:rule){'const_implies_const'}
      operator ">"
      constant 0
      conditional_operator "!="
      conditional_constant "0"
    end
  end
end
