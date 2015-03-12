class Friendship
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uid, type: String
  field :name, type: String
  belongs_to :user, inverse_of: 'friendships'
  belongs_to :friend, class_name: 'User', inverse_of: 'friend_users', primary_key: :uid, foreign_key: :uid

  validates_presence_of :uid
  validates_presence_of :name

  validates :user_id, uniqueness: {scope: [:uid]}, presence: true
end
