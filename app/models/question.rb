class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :vote

  has_many :answers

  validates_presence_of :title
end
