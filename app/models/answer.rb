class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  embedded_in :question

  validates_presence_of :title
end
