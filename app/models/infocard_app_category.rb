class InfocardAppCategory
  include Mongoid::Document
  include Mongoid::Timestamps

  # 类型字段
  field :title,       type: String
  field :logo,        type: String

  validates :title, uniqueness: true, presence: true

  has_many :infocards
end