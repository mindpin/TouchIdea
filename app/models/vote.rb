class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :finish_at, type: Time
  field :token, type: String
  field :url, type: String

  belongs_to :user, inverse_of: :votes
  has_many :vote_items
  has_and_belongs_to_many :voted_users, class_name: 'User', inverse_of: nil
  # todo images
  # has_many images

  accepts_nested_attributes_for :vote_items, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
  validates_presence_of :finish_at
  validates :token,    uniqueness: true,    presence: true

  scope :recent, -> { desc(:id) }
  scope :not_finished, -> { where(:finish_at.gt => Time.now) }
  scope :not_voted, -> (user) { not_finished.where({:voted_user_ids.nin => [user.id]}) }
  #scope :by_user, -> (user) { any_of({:user_id => user.id}, {:user_ids.in => [user.id]}, {:invite_uids.in => [user.uid]}) }


  def self.parse(token)
    Vote.where(token: token).first
  end

  def finished?
    Time.now > finish_at.end_of_day
  end

  def build_uniq_token_if_blank
    until !self.token.blank?
      tmp = randstr
      self.token = tmp unless Vote.where(token: tmp).first
    end
  end

  def self.rand_next user
    n = (0..Vote.not_voted(user).count-1).to_a.sample
    not_voted(user).skip(n).first
  end

  protected
  before_create :fill_vote_items_user
  def fill_vote_items_user
    vote_items.each do |vote_item|
      vote_item.user = self.user
    end
  end

  before_validation :init_token
  def init_token
    build_uniq_token_if_blank if self.token.blank?
  end

  def randstr(length=6)
    base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    size = base.size
    re = '' << base[rand(size-10)]
    (length - 1).times {
      re << base[rand(size)]
    }
    re
  end
end
