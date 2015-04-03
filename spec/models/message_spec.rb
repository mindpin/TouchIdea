require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should validate_presence_of :vote_id }
  it { should validate_presence_of :to_id }

  describe "create a valid message" do
    before(:each) do
      @user = create(:user)
      @vote = create(:vote_with_vote_item, user: @user)
      @vote_item = @vote.vote_items.first
      @message = create(:message, to: @user, vote: @vote)
    end

    it { @message.should be_valid }
    it { @message.read?.should == false}
    it do
      @message.read!.should == true
      @message.read?.should == true
    end
  end
end

