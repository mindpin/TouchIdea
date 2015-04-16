FactoryGirl.define do
  factory :vote_item do
    sequence(:title){|n| "vote_item #{n}"}
    factory :extra_vote_item do
      is_extra true
    end
  end

end
