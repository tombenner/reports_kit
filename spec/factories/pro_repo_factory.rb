FactoryGirl.define do
  factory :pro_repo, class: Pro::Repo do
    sequence(:full_name) { |i| "foo/bar#{i}" }
  end
end
