FactoryGirl.define do
  factory :vote do
    sequence(:title){|n| "title #{n}"}
    factory :vote_with_vote_item, :parent => :vote do
      before(:create) do |vote|
        build(:vote_item, vote: vote)
      end
    end
    factory :vote_with_rand_vote_item, :parent => :vote do
      before(:create) do |vote|
        rand(1..3).times do
          build(:vote_item, vote: vote)
        end
      end
    end
  end
end
