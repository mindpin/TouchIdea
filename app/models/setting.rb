class Setting
  include Mongoid::Document
  field :key, type: String
  field :value, type: String

  belongs_to :user

  validates_presence_of :user_id
  validates_presence_of :key
  validates_presence_of :value

  validates :key, uniqueness: {scope: [:user_id, :key]}, presence: true

  def true?
    self.value == 'true'
  end

  def false?
    self.value == 'false'
  end
end
