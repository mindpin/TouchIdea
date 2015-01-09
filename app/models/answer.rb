class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :question
  
  has_many :answer_records

  accepts_nested_attributes_for :answer_records, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title
end
