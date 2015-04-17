class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  #field :content, type: String
  field :read_at, type: Time
  # in %i[voted_vote_has_new_select own_vote_item_be_selected vote_has_new_select vote_item_be_selected]
  field :style,    type: Symbol
  field :total,    type: Integer, default: 1
  belongs_to :vote
  belongs_to :user, inverse_of: 'messages'
  belongs_to :to, inverse_of: 'notifies', class_name: 'User'
  #validates_presence_of :content
  validates_presence_of :vote_id
  validates_presence_of :to_id
  validates_presence_of :style

  scope :recent, -> { desc(:updated_at) }
  scope :unread, -> { where(read_at: nil) }
  scope :read_order, -> { asc(:read_at) }

  def read!
    update_attribute :read_at, Time.now if self.read_at.blank?
  end

  def read?
    !!read_at
  end

  def self.notify to_user, vote, style
    message = where(to: to_user, style: style, vote: vote, read_at: nil).first
    if message
      message.inc :total => 1
    else
      message = create(to: to_user, style: style, vote: vote, total: 1)
    end
    message
  end

  # 我参加的（别人创建的）议题增加了（别人创建的）选项
  def self.notify_voted_vote_has_new_select vote_item, from_user
    vote = vote_item.vote
    vote_creator = vote.user
    vote.voted_users.each do |user|
      if user != from_user and # 自己操作的不提醒
        user != vote_creator and # 议题的创建者为别人
        user.get_setting_value(NotificationSetting::JOINED_VOTES_ADD_VOTE_ITEM)
        notify user, vote, :voted_vote_has_new_select 
      end
    end
  end

  # 我（在别人的议题中）（自己）创建的选项被（别人）投票了
  def self.notify_vote_item_owner_be_selected vote_item, from_user
    vote_item_creator = vote_item.user
    if from_user != vote_item_creator and # 自己操作的不提醒
      vote_item_creator != vote_item.vote.user and # 别人的议题
      vote_item_creator.get_setting_value(NotificationSetting::CREATED_VOTE_ITEMS_ADD_PRAISE) # 设置了不提醒的
    notify vote_item_creator, vote_item.vote, :own_vote_item_be_selected 
    end
  end

  # 我（自己）创建的议题增加了（别人创建的）选项
  def self.notify_vote_has_new_select vote_item, from_user
    vote_creator = vote_item.vote.user
    notify vote_creator, vote_item.vote, :vote_has_new_select if vote_creator != from_user and vote_creator.get_setting_value(NotificationSetting::CREATED_VOTES_ADD_VOTE_ITEM)
  end

  # 我（自己）创建的议题中有任意（不管是谁创建的）选项被（别人）投票了
  def self.notify_vote_item_be_selected vote_item, from_user
    vote_creator = vote_item.vote.user
    notify vote_creator, vote_item.vote, :vote_item_be_selected if vote_creator != from_user and vote_creator.get_setting_value(NotificationSetting::CREATED_VOTES_ADD_PRAISE)
  end
end
