# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    name "Section 1"
    sequence :order
    association :survey
  end
end
