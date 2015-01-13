class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :finish_at, type: Time
  field :invite_uids, type: Array, default: []

  belongs_to :user, inverse_of: :votes
  has_many :questions
  has_and_belongs_to_many :users, inverse_of: 'invited_votes'
  has_and_belongs_to_many :voted_users, class_name: 'User', inverse_of: nil

  accepts_nested_attributes_for :questions, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
  validates_presence_of :finish_at

  scope :recent, -> { desc(:id) }
  scope :by_user, -> (user) { any_of({:user_id => user.id}, {:user_ids.in => [user.id]}) }

  def answered_by? user
    questions.map{|question| question.answered_by?(user)}.uniq == [true]
  end

  def finished?
    Time.now >= finish_at or voted_users.count == invite_uids.count
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

  before_create :add_self_to_invite_uids
  def add_self_to_invite_uids
    invite_uids.reject!{|uid| uid == ""}
    invite_uids << user.uid unless invite_uids.include?(user.uid)
  end

  before_create :add_users_by_invite_uids
  def add_users_by_invite_uids
    self.users = User.where(:uid.in => invite_uids).to_a
  end

  before_update :add_to_voted_users
  def add_to_voted_users
    self.voted_users = questions.map(&:answers).flatten.map(&:users).flatten.compact.uniq
  end
end
