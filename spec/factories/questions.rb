# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    sequence :question_order
    question "What?"
    association :section
    question_type "Text"
    code "What"
    after_create do |survey|
      StaticModelPreloader.load
    end
  end
end
