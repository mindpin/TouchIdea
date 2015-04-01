require 'rails_helper'

RSpec.describe Vote, type: :model do
  it { should validate_presence_of :title }
  it { should validate_presence_of :finish_at }
  it "should be valid?" do
    create(:vote).should be_valid
  end

  describe "#next user" do
    before(:each) do
      @user = create(:user)
      @vote = create(:vote, voted_users: [@user])
      @finished_vote = create(:vote, finish_at: 7.day.ago)
      3.times.each{ create(:vote, finish_at: 7.day.from_now)}
    end

    it "@vote.rand_next user should not be nil" do
      30.times.each do 
        @vote.rand_next(@user).should_not be_nil
      end
    end

    it "@vote.rand_next user should not be @vote" do
      30.times.each do 
        @vote.rand_next(@user).should_not == @vote
      end
    end

    it "@vote.rand_next user should not be @finished_vote" do
      30.times.each do 
        @vote.rand_next(@user).should_not == @finished_vote
      end
    end

  end
end
