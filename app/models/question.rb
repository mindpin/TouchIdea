class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :vote

  has_many :answers

  accepts_nested_attributes_for :answers, :reject_if => :all_blank, :allow_destroy => true

  validates_presence_of :title

  def answered_by? user
    answers.map{|answer| answer.answered_by?(user)}.include?(true)
  end

  protected
  before_create :clear_voters_if_new_record
  def clear_voters_if_new_record
    vote.voted_users.clear if new_record?
  end
end
