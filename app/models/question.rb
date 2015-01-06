class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  embedded_in :vote

  embeds_many :answers

  validates_presence_of :title
end
