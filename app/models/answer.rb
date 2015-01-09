class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :question
  
  has_and_belongs_to_many :users, inverse_of: nil

  attr_accessor :controller

  validates_presence_of :title

  def answered_by? user
    users.include?(user)
  end
end
