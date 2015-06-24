class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  # for search
  include VoteSearchConfig
  
  include Infocard::VoteMethods

  field :title, type: String
  field :finish_at, type: Time#, default: ->{ 7.days.from_now }
  field :token, type: String
  field :url, type: String
  # 创建当周的第一天,用于排序
  field :first_day, type: String, default: -> { Time.now.beginning_of_week.strftime '%Y%m%d' }
  field :voted_users_count, type: Integer, default: 0

  belongs_to :user, inverse_of: :votes
  has_many :vote_items
  has_and_belongs_to_many :voted_users, class_name: 'User', inverse_of: :voted_votes
  # todo images
  # has_many images

  accepts_nested_attributes_for :vote_items, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
  #validates_presence_of :finish_at
  validates :token,    uniqueness: true,    presence: true

  scope :recent, -> { desc(:id) }
  scope :hot, -> { desc(:first_day, :voted_users_count).recent}
  scope :not_finished, -> { where(:finish_at.gt => Time.now) }
  scope :not_voted, -> (user) { where({:voted_user_ids.nin => [user.id]}) }
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

  def vote_items_count
    vote_items.count
  end

  def praised_count
    vote_items.to_a.sum{|vote_item| vote_item.praised_count }
  end

  def added_vote_item_by? user
    vote_items.any?{|vote_item| vote_item.user == user and vote_item.is_extra and !vote_item.new_record?}
  end

  def self.rand_next user
    n = (0..not_voted(user).count-1).to_a.sample
    not_voted(user).skip(n).first
  end

  # 根据不同的用户返回不同的 vote_items 排列顺序
  def vote_items_rand_order_by_user user
    user_ord = (user.created_at.to_i % 43) + 1 
    # 43是随便取的一个素数，
    # 可以随意换个大于选项个数的2~3位的数字代替, 
    # +1为使之不为0
    vote_items.sort {|x, y| 
      (x.ord % user_ord) <=> (y.ord % user_ord)
    }
  end

  # 判断是否被指定 user 投票过
  def has_voted_by?(user)
    voted_users.include? user
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
