# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :supplementary_file do
      multi_name "MyString"
      batch_file nil
    end
end