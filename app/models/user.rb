# encoding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:weibo]

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  # field :confirmation_token,   type: String
  # field :confirmed_at,         type: Time
  # field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time
  field :uid,    type: String
  field :nickname,    type: String

  # https://github.com/mongoid/mongoid/issues/3626#issuecomment-64700154
  def self.serialize_from_session(key, salt)
    (key = key.first) if key.kind_of? Array
    (key = BSON::ObjectId.from_string(key['$oid'])) if key.kind_of? Hash

    record = to_adapter.get(key)
    record if record && record.authenticatable_salt == salt
  end

  def self.serialize_into_session(record)
    [record.id.to_s, record.authenticatable_salt]
  end

  has_many :user_tokens
  has_many :votes
  has_and_belongs_to_many :invited_votes, class_name: 'Vote', inverse_of: 'users'
  has_many :friendships, inverse_of: 'user'
  has_many :friend_users, inverse_of: 'friend', class_name: 'Friendship', primary_key: :uid, foreign_key: :uid

  def friends
    friendships.includes(:friend).map(&:friend).compact
  end

  def apply_omniauth(omniauth)
    #add some info about the user
    #self.name = omniauth['user_info']['name'] if name.blank?
    #self.nickname = omniauth['user_info']['nickname'] if nickname.blank?

    if omniauth['credentials'].blank?
      user_tokens.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
    else
      user_tokens.build(:provider => omniauth['provider'], 
                        :uid => omniauth['uid'],
                        :token => omniauth['credentials']['token'], 
                        :expires_at => omniauth['credentials']['expires_at'])
    end
    #self.confirm!# unless user.email.blank?
  end

  def password_required?
    false
  end

  def email_required?
    false
  end

  protected
  after_create :get_weibo_friends_bilateral, :add_to_vote_users
  def get_weibo_friends_bilateral
    client = WeiboOAuth2::Client.new
    user_token = user_tokens.last
    client.get_token_from_hash access_token: user_token.token, expires_at: user_token.expires_at
    friends_bilateral = client.friendships.friends_bilateral(uid)
    friendships.create friends_bilateral.users.map {|user| {name: user.name, uid: user.id} }
  end

  def add_to_vote_users
    Vote.where(:invite_uids.in => [self.uid]).each do |vote|
      vote.users << self
    end
  end
end
