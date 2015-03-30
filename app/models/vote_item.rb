class VoteItem
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :praised_count, type: Integer, default: 0

  validates_presence_of :title

  belongs_to :vote
  belongs_to :user
end
