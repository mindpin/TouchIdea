require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :finish_at }
  
  describe "@user create a @vote" do
    before(:each) do
      @user = create(:user)
      @vote = create(:vote, user: @user)
    end

    it{ @vote.user.should == @user }
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
end
