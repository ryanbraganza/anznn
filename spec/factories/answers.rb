# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :answer do
    association :response
    association :question
    answer_value "100"
  end
end
