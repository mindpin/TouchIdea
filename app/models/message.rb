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

  # 我参加的议题增加选项时
  def self.notify_voted_vote_has_new_select vote_item
    vote_item.vote.voted_users.each do |user|
      user.notifies.create style: :voted_vote_has_new_select, vote: vote_item.vote if user.get_setting_value(NotificationSetting::JOINED_VOTES_ADD_VOTE_ITEM)
    end
  end

  # 我创建的选项被投票时
  def self.notify_vote_item_owner_be_selected vote_item
    user = vote_item.user
    user.notifies.create style: :own_vote_item_be_selected, vote: vote_item.vote if user.get_setting_value(NotificationSetting::CREATED_VOTE_ITEMS_ADD_PRAISE)
  end

  # 我发起的议题增加选项时
  def self.notify_vote_has_new_select vote_item
    user = vote_item.vote.user
    user.notifies.create(style: :vote_has_new_select, vote: vote_item.vote) if user.get_setting_value(NotificationSetting::CREATED_VOTES_ADD_VOTE_ITEM)
  end

  # 我创建的议题中有任意选项被人投票了
  def self.notify_vote_item_be_selected vote_item
    user = vote_item.vote.user
    user.notifies.create style: :vote_item_be_selected, vote: vote_item.vote if user.get_setting_value(NotificationSetting::CREATED_VOTES_ADD_PRAISE)
  end
end
