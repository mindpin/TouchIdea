class Message
  include Mongoid::Document
  include Mongoid::Timestamps
  field :content, type: String
  field :read_at, type: Time
  belongs_to :vote
  belongs_to :user, inverse_of: 'messages'
  belongs_to :to, inverse_of: 'notifies', class_name: 'User'
  #validates_presence_of :content
  validates_presence_of :vote_id
  validates_presence_of :to_id

  scope :recent, -> { desc(:id) }
  scope :unread, -> { where(read_at: nil) }

  def read!
    update_attribute :read_at, Time.now if self.read_at.blank?
  end

  def read?
    !!read_at
  end
end
