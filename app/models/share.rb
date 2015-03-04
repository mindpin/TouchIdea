class Share
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uids, type: Array
  field :shared, type: Mongoid::Boolean, default: false
  belongs_to :vote

  validates_presence_of :uids

  scope :un_shared, -> {where(shared: false)}

  def is_shared?
    shared
  end

  def share!
    if !shared and vote.user.get_setting('share invitation').true?
      ShareToWeibo.new.user_invite_by_uids(vote.user, vote, uids)
      update_attribute :shared, true
    end
  end
end
