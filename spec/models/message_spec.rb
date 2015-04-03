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

  describe "notify" do
    before(:each) do
      @vote_creator = create(:user)
      @vote = create(:vote_with_vote_item, user: @vote_creator)
      @vote_item = @vote.vote_items.first
      @new_select_owner = create(:user)
    end

    it "我创建的选项被人投票了" do
      @vote_item.praise_by @new_select_owner
      Message.notify_vote_item_owner_be_selected @vote_item
      @vote_creator.notifies.first.content.should == '我创建的选项被人投票了'
    end

    it "我创建的议题增加了选项" do
      @new_vote_item = create(:vote_item, vote: @vote)
      Message.notify_vote_has_new_select @new_vote_item
      @vote_creator.notifies.first.content.should == '我创建的议题增加了选项'
    end

    it "我创建的议题中有任意选项被人投票了" do
      @vote_item.praise_by @new_select_owner
      Message.notify_vote_item_be_selected @vote_item
      @vote_creator.notifies.first.content.should == '我创建的议题中有任意选项被人投票了'
    end

    it "我参加的议题增加了选项" do
      @vote_item.praise_by @new_select_owner
      @new_vote_item = create(:vote_item, vote: @vote, user: @new_select_owner)
      Message.notify_voted_vote_has_new_select @new_vote_item
      @new_select_owner.notifies.where(content: '我参加的议题增加了选项').first.should_not be_nil
    end
  end
end

