class Vote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :finish_at, type: Time
  field :invite_uids, type: Array

  belongs_to :user, inverse_of: :votes
  embeds_many :questions
  has_and_belongs_to_many :users, inverse_of: 'invited_votes'

  validates_presence_of :title
  validates_presence_of :finish_at

  scope :recent, -> { desc(:id) }
  scope :by_user, -> (user) { any_of({:user_id => user.id}, {:user_ids.in => [user.id]}) }
end
