require 'rails_helper'

RSpec.describe VoteItem, type: :model do
  it { should validate_presence_of :title }

  describe "@user create @vote with @vote_item" do
    before(:each) do
      @user = create(:user)
      @vote = create(:vote_with_vote_item, user: @user)
      @vote_item = @vote.vote_items.first
    end

    it { @vote_item.should be_valid}
    it { @vote_item.user.should == @user}

    it "#praised_users << @user, @user.praised_vote_items should include @vote_item"  do
      @vote_item.praised_users << @user
      @user.praised_vote_items.should include(@vote_item)
    end

    describe "#praise_by @user" do
      before(:each) do
        @result = @vote_item.praise_by(@user)
      end
      it { @result.should == true }
      it "praise_by twice return nil" do
        @vote_item.praise_by(@user).should be_nil
      end
      it { @vote_item.praised_users.should include(@user) }
      it "@vote voted_users should include @user" do
        @vote.voted_users.should include(@user)
      end

      it "#praised_by?(user) should == true" do
        @vote_item.praised_by?(@user).should == true
      end
    end
  end
end
