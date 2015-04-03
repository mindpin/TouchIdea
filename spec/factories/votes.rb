FactoryGirl.define do
  factory :vote do
    title "MyString"
    finish_at "2015-03-30 09:25:28"
    factory :vote_with_vote_item, :parent => :vote do
      before(:create) do |vote|
        build(:vote_item, vote: vote)
      end
    end
  end
end
