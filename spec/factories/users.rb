FactoryGirl.define do
  factory :basic_user, class: :user do
    first_name "Fred"
    last_name "Bloggs"
    password "Pas$w0rd"
    sequence(:email) { |n| "#{n}@intersect.org.au" }

    factory :user do
      association :hospital
    end

    factory :super_user do
      role { |r| Role.superuser_roles.first || r.association(:role, name: Role::SuperUserRole) }
    end
  end

end