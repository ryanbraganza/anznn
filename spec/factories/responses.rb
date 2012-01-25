# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    association :survey
    association :user
    baby_code "Blah"
  end
end