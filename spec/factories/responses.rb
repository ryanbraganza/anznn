# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :response do
    association :survey
    association :user
    association :hospital
    baby_code "Blah"
    submitted_status Response::STATUS_UNSUBMITTED
    year_of_registration "2003"
  end
end
