class Question
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :vote

  has_many :answers

  accepts_nested_attributes_for :answers, :reject_if => :reject_if_title_blank, :allow_destroy => true

  validates_presence_of :title

  def answered_by? user
    answers.map{|answer| answer.answered_by?(user)}.include?(true)
  end

  def answered?
    answers.any?(&:answered?)
  end

  protected
  before_create :clear_voters_if_new_record
  def clear_voters_if_new_record
    if new_record?
      vote.voted_users.clear
      vote.is_clear_voted_users = true
    end
  end

  def reject_if_title_blank(attributes)
    exists = attributes['id'].present?
    empty = attributes[:title].blank?
    attributes.merge!({:_destroy => 1}) if exists and empty
    return (!exists and empty)
  end
end
