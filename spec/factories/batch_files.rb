# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :batch_file do
    association :survey
    association :user
    association :hospital
    file_file_name "Blah"
    year_of_registration 2012
  end
end