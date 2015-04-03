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
  end
end
