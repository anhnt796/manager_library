FactoryBot.define do
  factory :user do
    name {Faker::Name.name}
    contact {Faker::Address.full_address}
    email {Faker::Internet.email}
    password {Faker::Internet.password(6,6)}
    confirmed_at Date.today
  end

  factory :admin, class: User do
    name "Admin"
    contact {Faker::Address.full_address}
    email {Faker::Internet.email}
    password {Faker::Internet.password(6,6)}
    role 0
    confirmed_at Date.today
  end

  factory :librarian, class: User do
    name "Librarian"
    contact {Faker::Address.full_address}
    email {Faker::Internet.email}
    password {Faker::Internet.password(6,6)}
    role 1
    confirmed_at Date.today
  end
end
