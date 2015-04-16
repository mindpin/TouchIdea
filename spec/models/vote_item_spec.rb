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

    it "@vote_item.praised_count" do
      @vote_item.praised_count.should == 0
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

      it "@vote_item.praised_count" do
        @vote_item.praised_count.should == 1
      end

      it "@vote.voted_users_count" do
        @vote.voted_users_count.should == 1
      end

      describe "#cancel_praise_by @user" do
        before(:each) do
          @vote_item.cancel_praise_by(@user).should == true
          @vote_item.reload
        end

        it "@vote_item.praised_count" do
          @vote_item.praised_count.should == 0
        end

        it "@vote_item.praised_count" do
          @vote_item.praised_users.should_not include(@user)
        end

        it "@vote.voted_users_count" do
          @vote.voted_users_count.should == 0
        end

        it "@vote voted_users should not include @user" do
          @vote.voted_users.should_not include(@user)
        end
      end
    end

    describe "@other add vote_item" do
      before(:each) do
        @other = create(:user)
        @new_vote_item = create(:vote_item, user: @other, vote: @vote)
      end

      it do
        @vote.vote_items_count.should == 2
      end

      it do
        @vote.vote_items.should include(@new_vote_item)
      end

      it "@vote.voted_users_count" do
        @vote_item.praise_by(@user)
        @new_vote_item.praise_by @other
        @vote.voted_users_count.should == 2
        @new_vote_item.praise_by @other
        @vote.voted_users_count.should == 2
      end
    end
  end
end
