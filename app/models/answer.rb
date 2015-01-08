class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :question

  validates_presence_of :title
end
