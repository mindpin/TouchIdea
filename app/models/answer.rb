class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :question
  
  has_many :answer_records

  validates_presence_of :title
end
