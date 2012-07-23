# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :survey do
    sequence(:name) { |n| "mysurvey #{n}" }
    after_create do |survey|
      StaticModelPreloader.load
    end
  end
end
