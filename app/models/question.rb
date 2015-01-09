class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :vote

  has_many :answers

  accepts_nested_attributes_for :answers, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
end
