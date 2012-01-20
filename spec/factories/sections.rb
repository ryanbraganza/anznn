# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    sequence :order
    association :survey
  end
end
