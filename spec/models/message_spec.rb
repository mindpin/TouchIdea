require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should validate_presence_of :vote_id }
  it { should validate_presence_of :to_id }
  it { should validate_presence_of :style }

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
      @praise_user = create(:user)
    end

    it "我创建的选项被投票时" do
      @new_vote_item = create(:extra_vote_item, vote: @vote, user: @new_select_owner)
      @new_vote_item.praise_by @praise_user
      @new_select_owner.notifies.map(&:style).should include :own_vote_item_be_selected
    end

    it "我发起的议题增加选项时" do
      @new_vote_item = create(:vote_item, vote: @vote, user: @new_select_owner)
      @vote_creator.notifies.map(&:style).should include :vote_has_new_select
    end

    it "我创建的议题中有任意选项被人投票了" do
      @vote_item.praise_by @praise_user
      @vote_creator.notifies.map(&:style).should include :vote_item_be_selected
    end

    it "我参加的议题增加选项时" do
      @vote_item.praise_by @vote_creator
      @vote_item.praise_by @praise_user
      @new_vote_item = create(:vote_item, vote: @vote, user: @new_select_owner)
      @praise_user.notifies.map(&:style).should include :voted_vote_has_new_select
      @vote_creator.notifies.map(&:style).should include :voted_vote_has_new_select
    end

    describe "如果用户设置不提醒" do
      it "我创建的选项被投票时" do
        @vote_creator.set_setting(NotificationSetting::CREATED_VOTE_ITEMS_ADD_PRAISE, false)
        @vote_item.praise_by @praise_user
        @vote_creator.notifies.map(&:style).should_not include :own_vote_item_be_selected
      end

      it "我发起的议题增加选项时" do
        @vote_creator.set_setting(NotificationSetting::CREATED_VOTES_ADD_VOTE_ITEM, false)
        @new_vote_item = create(:vote_item, vote: @vote, user: @new_select_owner)
        @vote_creator.notifies.map(&:style).should_not include :vote_has_new_select
      end

      it "我创建的议题中有任意选项被人投票了" do
        @vote_creator.set_setting(NotificationSetting::CREATED_VOTES_ADD_PRAISE, false)
        @vote_item.praise_by @praise_user
        @vote_creator.notifies.map(&:style).should_not include :vote_item_be_selected
      end

      it "我参加的议题增加选项时" do
        @vote_creator.set_setting(NotificationSetting::JOINED_VOTES_ADD_VOTE_ITEM, false)
        @praise_user.set_setting(NotificationSetting::JOINED_VOTES_ADD_VOTE_ITEM, false)
        @vote_item.praise_by @vote_creator
        @vote_item.praise_by @praise_user
        @new_vote_item = create(:vote_item, vote: @vote, user: @new_select_owner)
        @praise_user.notifies.map(&:style).should_not include :voted_vote_has_new_select
        @vote_creator.notifies.map(&:style).should_not include :voted_vote_has_new_select
      end
    end
  end
end

