require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should validate_presence_of :title }
  #it { should validate_presence_of :finish_at }
  
  describe "@user create a @vote" do
    before(:each) do
      @user = create(:user)
      @vote = create(:vote, user: @user)
    end

    it{ @vote.user.should == @user }

    it "#voted_users << @user, @user.voted_votes should include @vote"  do
      @vote.voted_users << @user
      @user.reload
      @user.voted_votes.should include(@vote)
    end

    it "#voted_users_count" do
      @vote.voted_users_count.should == 0
    end
  end

  it "return nil when has not not_voted vote" do
    @user = create(:user)
    @vote = create(:vote, voted_users: [@user])
    Vote.rand_next(@user).should be_nil
  end

  describe "#next user" do
    before(:each) do
      @user = create(:user)
      @finished_vote = create(:vote, finish_at: 7.day.ago)
      3.times.each{ create(:vote, finish_at: 7.day.from_now)}
    end

    it "Vote.rand_next user should not be nil" do
      30.times.each do 
        Vote.rand_next(@user).should_not be_nil
      end
    end

    it "Vote.rand_next user should not be @finished_vote" do
      30.times.each do 
        Vote.rand_next(@user).should_not == @finished_vote
      end
    end
  end

  describe "scope hot" do
    before(:each) do
      @user1 = create(:user)
      @user2 = create(:user)
      @vote1 = create(:vote_with_vote_item, user: @user1)
      @vote2 = create(:vote_with_vote_item, user: @user1)
    end

    it "所有相同，则按默认排序" do
      Vote.hot.first.should == @vote2
      Vote.hot.last.should == @vote1
    end

    describe "先按first_day相同" do
      it "则按投票数排列，若相同，则默认排序" do
        @vote3 = create(:vote_with_vote_item, user: @user1)
        @vote3.vote_items.first.praise_by @user1
        @vote3.vote_items.first.praise_by @user2
        @vote2.vote_items.first.praise_by @user1
        Vote.hot[0].should == @vote3
        Vote.hot[1].should == @vote2
        Vote.hot[2].should == @vote1
      end
    end

    it "先按first_day降序排列，如相同，则按投票数排列" do
      @vote3 = create(:vote_with_vote_item, user: @user1, first_day: '99991231')
      @vote2.vote_items.first.praise_by @user1
      @vote2.vote_items.first.praise_by @user2
      @vote1.vote_items.first.praise_by @user1
      Vote.hot[0].should == @vote3
      Vote.hot[1].should == @vote2
      Vote.hot[2].should == @vote1
    end
  end

  describe "#praised_count" do
    before(:each) do
      @user1 = create(:user)
      @user2 = create(:user)
      @vote = create(:vote_with_vote_item, user: @user1)
      @vote_item = @vote.vote_items.first
    end

    it do
      @vote.praised_count.should == 0
    end

    it do
      @vote_item.praise_by(@user1)
      @vote_item.praise_by(@user2)
      @vote.praised_count.should == 2

      @new_vote_item = create(:extra_vote_item, user:@user2, vote: @vote)
      @new_vote_item.praise_by(@user2)
      @vote.praised_count.should == 3
    end
  end

  it "#added_vote_item_by?" do
    @user1 = create(:user)
    @user2 = create(:user)
    @vote = create(:vote_with_vote_item, user: @user1)
    @vote.added_vote_item_by?(@user1).should == false
    create(:extra_vote_item, vote: @vote, user: @user1).should be_valid
    @vote.added_vote_item_by?(@user1).should == true
    # 只能创建一个
    build(:extra_vote_item, vote: @vote, user: @user1).valid?.should == false

    @vote.added_vote_item_by?(@user2).should == false
  end

  # 还是有可能会遇见出错的(当阵列足够大时)，因为两个产生的user_ord一样，但是没有必要去纠结。
  it "vote_items_rand_order_by_user" do
    @test_array_count = 5
    @users = []
    @test_array_count.times{ @users << create(:user); sleep(1) }
    @vote = create(:vote_with_10_vote_item, user: @users.first)
    @array_vote_items = @users.map do |user|
      Vote.vote_items_rand_order_by_user(@vote.id, user)
    end
    @array_vote_items.each_with_index do |vote_items, index|
      (index+1).upto(@array_vote_items.length-1).each do |i|
        vote_items.should_not == @array_vote_items[i]
      end
    end
  end
end
