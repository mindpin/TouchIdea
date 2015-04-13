class Feedback
  include Mongoid::Document
  include Mongoid::Timestamps

  field :content,  type: String
  belongs_to :user

  module UserMethods
    def self.included(base)
      base.has_many :feedbacks
    end
  end
end