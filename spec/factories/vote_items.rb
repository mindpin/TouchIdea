FactoryGirl.define do
  factory :vote_item do
    title "MyString"
    factory :extra_vote_item do
      is_extra true
    end
  end

end
