class NotificationSetting
  # 我发起的议题被投票时
  CREATED_VOTES_ADD_PRAISE      = 'CREATED_VOTES_ADD_PRAISE'
  # 我发起的议题增加选项时
  CREATED_VOTES_ADD_VOTE_ITEM   = 'CREATED_VOTES_ADD_VOTE_ITEM'
  # 我创建的选项被投票时
  CREATED_VOTE_ITEMS_ADD_PRAISE = 'CREATED_VOTE_ITEMS_ADD_PRAISE'    
  # 我参加的议题增加选项时
  JOINED_VOTES_ADD_VOTE_ITEM    = 'JOINED_VOTES_ADD_VOTE_ITEM'

  include Mongoid::Document
  field :key, type: String
  field :value, type: Boolean

  belongs_to :user

  validates_presence_of :user_id
  validates_presence_of :key
  validates_presence_of :value

  validates :key, uniqueness: {scope: [:user_id, :key]}, presence: true

  module UserMethods
    def self.included(base)
      base.has_many :notification_settings
    end

    def get_setting_value(key, default_value = true)
      setting = notification_settings.where(key: key).first_or_create(value: default_value)
      setting.value
    end

    def set_setting(key, value)
      value = true if value == 'true'
      value = false if value == 'false'
      setting = notification_settings.where(key: key).first
      if setting.blank?
        setting = notification_settings.build(key: key)
      end
      setting.value = value
      setting.save
      setting.value
    end
  end
end
