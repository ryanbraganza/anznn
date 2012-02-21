# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :hospital do
      sequence(:name) { |n| "Some Hospital #{n}" }
      sequence(:state) do |n| #Pick a random, real state
        states = %w(ACT NSW Qld SA NT Vic WA North\ Island South\ Island)
        states[n % states.length]
      end
      sequence(:abbrev)
    end
end