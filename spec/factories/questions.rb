# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    sequence :order
    question "What?"
    association :section
    question_type "Text"
    code "What"
  end
end
