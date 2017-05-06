FactoryGirl.define do
  factory :repo do
    sequence(:full_name) { |i| "foo/bar#{i}" }
  end
end
