class VoteItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :praised_count, type: Integer, default: 0

  validates_presence_of :title

  belongs_to :vote, inverse_of: :vote_items
  belongs_to :user, inverse_of: :vote_items

  # 赞过的用户
  has_and_belongs_to_many :praised_users, class_name: 'User', inverse_of: :praised_vote_items

  def praise_by user
    unless praised_by?(user)
      self.praised_users << user
      self.inc(praised_count: 1)
      unless self.vote.voted_users.include?(user)
        self.vote.voted_users << user 
        self.vote.inc(voted_users_count: 1)
      end
      Message.notify_vote_item_be_selected self
      Message.notify_vote_item_owner_be_selected self
      true
    end
  end

  def praised_by? user
    self.praised_users.include?(user)
  end

  protected
  after_create :notify_if_vote_owner_create
  def notify_if_vote_owner_create
    Message.notify_vote_has_new_select self if user != vote.user
  end

  after_create :notify_voted_vote_has_new_select
  def notify_voted_vote_has_new_select
    Message.notify_voted_vote_has_new_select self
  end
end
