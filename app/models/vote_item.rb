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
    unless self.praised_users.include?(user)
      self.praised_users << user
      self.vote.voted_users << user unless self.vote.voted_users.include?(user)
      true
    end
  end
end
