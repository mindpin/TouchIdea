class AnswerRecord
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :answer
  belongs_to :user
end
