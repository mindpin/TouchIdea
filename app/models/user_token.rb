class UserToken
  include Mongoid::Document
  include Mongoid::Timestamps
  field :provider,              type: String
  field :uid,              type: String
  belongs_to :user
end
