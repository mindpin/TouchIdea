class VoteItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :praised_count, type: Integer, default: 0
  field :is_extra, type: Boolean, default: false
  field :ord, type: Integer, default: -> { rand(1000) } # 随机生成随机数，用于议题中选项排序，对不同用户，选项随机位置显示

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
      Message.notify_vote_item_be_selected self, user
      Message.notify_vote_item_owner_be_selected self, user
      true
    end
  end

  def cancel_praise_by user
    if praised_by?(user)
      self.praised_users.delete user
      self.inc(praised_count: -1)
      unless self.vote.vote_items.map(&:praised_users).flatten.include?(user)
        self.vote.voted_users.delete user 
        self.vote.inc(voted_users_count: -1)
      end
      true
    end
  end

  def praised_by? user
    self.praised_users.include?(user)
  end

  protected
  after_create :notify_if_vote_owner_create
  def notify_if_vote_owner_create
    Message.notify_vote_has_new_select self, user
  end

  after_create :notify_voted_vote_has_new_select
  def notify_voted_vote_has_new_select
    Message.notify_voted_vote_has_new_select self, user
  end

  validate :user_only_create_one_extra_vote_item
  def user_only_create_one_extra_vote_item
    if vote and vote.added_vote_item_by?(user) and new_record?
      errors.add :user, :has_added_vote_item
    end
  end
end
