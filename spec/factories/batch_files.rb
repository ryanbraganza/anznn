# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :batch_file do
    association :survey
    association :user
    file_file_name "Blah"
  end
end