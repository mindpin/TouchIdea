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
end
