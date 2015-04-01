FactoryGirl.define do
  factory :user do
    sequence(:nickname){|n| "user#{n}"}
    sequence(:uid){|n| "uid:#{n}"}
  end
end

