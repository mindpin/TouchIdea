class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :finish_at, type: Time
  field :invite_uids, type: Array, default: []

  field :token, type: String

  belongs_to :user, inverse_of: :votes
  has_many :questions
  has_and_belongs_to_many :users, inverse_of: 'invited_votes'
  has_and_belongs_to_many :voted_users, class_name: 'User', inverse_of: nil
  has_many :shares

  attr_accessor :is_clear_voted_users

  accepts_nested_attributes_for :questions, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
  validates_presence_of :finish_at

  validates :token,    uniqueness: true,    presence: true

  scope :recent, -> { desc(:id) }
  scope :by_user, -> (user) { any_of({:user_id => user.id}, {:user_ids.in => [user.id]}) }


  def self.parse(token)
    Vote.where(token: token).first
  end

  def answered_by? user
    questions.map{|question| question.answered_by?(user)}.uniq == [true]
  end

  def answered?
    questions.any?(&:answered?)
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

  protected
  before_save :add_voter_to_answers_users
  def add_voter_to_answers_users
    questions.map(&:answers).flatten.each do |answer|
      unless answer.voter_id.blank?
        tmp = answer.voter_id
        answer.voter_id = nil
        answer.users << User.find(tmp)
      end
    end
  end

  before_validation :init_token
  def init_token
    build_uniq_token_if_blank if self.token.blank?
  end

  before_create :add_self_to_invite_uids
  def add_self_to_invite_uids
    invite_uids.reject!{|uid| uid == ""}
    invite_uids << user.uid unless invite_uids.include?(user.uid)
  end

  before_create :add_users_by_invite_uids_and_notify
  def add_users_by_invite_uids_and_notify
    tmp = User.where(:uid.in => invite_uids).to_a - self.users.to_a
    self.users = tmp
    tmp = tmp - [self.user]
    tmp.each do |u|
      user.invite_notify u, self
    end
  end

  before_update :add_users_by_invite_uids_and_notify_before_update
  def add_users_by_invite_uids_and_notify_before_update
    tmp = User.where(:uid.in => invite_uids).to_a - self.users.to_a
    self.users = tmp
    if changes['invite_uids']
      new_uids = changes['invite_uids'].last - changes['invite_uids'].first
      new_users = User.where(uid: new_uids)
      new_users.each do |u|
        user.invite_notify u, self
      end
    end
  end

  before_update :invite_new_user_by_weibo
  def invite_new_user_by_weibo
    if changes['invite_uids']
      new_uids = changes['invite_uids'].last - changes['invite_uids'].first
      shares.create(uids: new_uids.reject{|uid| uid.blank?}) if self.user.get_setting('share invitation').true? and !new_uids.blank?
    end
  end

  before_update :add_to_voted_users
  def add_to_voted_users
    if questions.count > 0
      array = questions.first.answers.map{|answer| answer.users.to_a}.flatten.uniq
      questions.to_a[1..-1].each do |question|
        array = array & question.answers.map{|answer| answer.users.to_a}.flatten.uniq
      end
      self.voted_users = array
    end
  end

  after_create :share_to_weibo
  def share_to_weibo
    shares.create(uids: invite_uids.reject{|uid| uid.blank? or uid == user.uid}) if user.get_setting('share invitation').true?
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
