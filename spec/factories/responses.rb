# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    association :survey
    association :user
    association :hospital
    sequence(:baby_code) { |n| "SomeBaby#{n}" }
    submitted_status Response::STATUS_UNSUBMITTED
    year_of_registration "2003"
  end
end
