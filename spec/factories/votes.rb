FactoryGirl.define do
  factory :vote do
    title "MyString"
    factory :vote_with_vote_item, :parent => :vote do
      before(:create) do |vote|
        build(:vote_item, vote: vote)
      end
    end
  end
end
