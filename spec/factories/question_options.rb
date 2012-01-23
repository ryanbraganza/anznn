# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question_option do
    association :question
    option_value "A"
    label "Answer A"
    sequence :option_order
  end
end