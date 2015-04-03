class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String
  field :read_at, type: Time
  belongs_to :vote
  belongs_to :user, inverse_of: 'messages'
  belongs_to :to, inverse_of: 'notifies', class_name: 'User'
  #validates_presence_of :content
  validates_presence_of :vote_id
  validates_presence_of :to_id

  scope :recent, -> { desc(:id) }
  scope :unread, -> { where(read_at: nil) }

  def read!
    update_attribute :read_at, Time.now if self.read_at.blank?
  end

  def read?
    !!read_at
  end

  #2.1 我参加的议题增加了选项
  def self.notify_voted_vote_has_new_select vote_item
    vote_item.vote.voted_users.each do |user|
      user.notifies.create content: '我参加的议题增加了选项', vote: vote_item.vote
    end
  end

  #2.2 我创建的选项被人投票了
  def self.notify_vote_item_owner_be_selected vote_item
    vote_item.user.notifies.create content: '我创建的选项被人投票了', vote: vote_item.vote
  end

  #2.3 我创建的议题增加了选项
  def self.notify_vote_has_new_select vote_item
    vote_item.vote.user.notifies.create content: '我创建的议题增加了选项', vote: vote_item.vote
  end

  #2.4 我创建的议题中有任意选项被人投票了
  def self.notify_vote_item_be_selected vote_item
    vote_item.vote.user.notifies.create content: '我创建的议题中有任意选项被人投票了', vote: vote_item.vote
  end
end
