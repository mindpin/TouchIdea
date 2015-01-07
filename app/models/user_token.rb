class UserToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :provider,              type: String
  field :uid,              type: String
  field :token,     type: String
  field :expires_at,     type: Time
  belongs_to :user
end
