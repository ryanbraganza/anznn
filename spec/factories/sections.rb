# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :section do
    name "Section 1"
    sequence :section_order
    association :survey
    after_create do |survey|
      StaticModelPreloader.load
    end
  end
end
