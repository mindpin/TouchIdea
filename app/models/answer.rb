class Answer
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  belongs_to :question
  
  has_and_belongs_to_many :users, inverse_of: nil

  attr_accessor :voter_id

  def answered_by? user
    users.include?(user)
  end

  def answered?
    !users.blank?
  end

  def voter
    User.find(voter_id) unless voter_id.blank?
  end

  protected
  before_save :add_voter_to_users
  def add_voter_to_users
    unless voter_id.blank?
      tmp = voter_id
      voter_id = nil
      users << User.find(tmp)
    end
  end
end
