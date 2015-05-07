class Infocard
  class Kind
    PRODUCT = 'PRODUCT'
    APP     = 'APP'
  end
  include Mongoid::Document
  include Mongoid::Timestamps

  # 类型字段
  field :kind,       type: String

  # 任何类型都有的字段
  field :title,      type: String  # 标题
  field :pictures,  type: Array # 多个图片 url
  field :logo,        type: String # logo url

  # 商品类型
  field :url,        type: String  # 原始 url
  field :price,      type: String # 价格
  field :from,       type: String # 来源（天猫，京东等）

  # 软件介绍类型
  field :homepage,     type: String # 软件官网
  field :producer,     type: String   # 生产商
  field :desc,         type: String  # 介绍

  # 只有 APP 类型的 infocard 才有这个关联
  has_and_belongs_to_many :infocard_app_categories

  # 向 urlinfo-service http api 发送请求，并把获取的信息保存 infocard
  def self.parse(url)
    # 编码 ^ ` 等字符
    url = URI.encode(url)
    # 编码 ? & 这两个字符
    url = URI.encode(url,"&?")
    # 经过两次编码后的 url 可以安全的作为 query 参数了
    urlinfo_url = "http://urlinfo.4ye.me/api/fetch_infocard?url=#{url}"

    uri = URI.parse(urlinfo_url)
    res = Net::HTTP.get_response(uri)
    json = JSON.parse(res.body)
    if json["status"] == "PARSED"
      infocard = Infocard.where(
        :kind  => Infocard::Kind::PRODUCT,
        :title => json["data"]["title"],
        :price => json["data"]["price"],
        :from  => json["data"]["from"]
      ).first
      if infocard.blank?
        infocard = Infocard.create(
          :kind  => Infocard::Kind::PRODUCT,
          :url   => url,
          :title    => json["data"]["title"],
          :pictures => json["data"]["image_urls"],
          :price    => json["data"]["price"],
          :from     => json["data"]["from"]
        )
      end
    elsif json["status"] == "SEO"
      infocard = Infocard.where(
        :kind  => Infocard::Kind::PRODUCT,
        :title => json["data"]["title"],
        :from  => json["data"]["from"]
      ).first
      if infocard.blank?
        infocard = Infocard.create(
          :kind  => Infocard::Kind::PRODUCT,
          :url   => url,
          :title    => json["data"]["title"],
          :from     => json["data"]["from"]
        )
      end
    end
    infocard
  end

  module VoteMethods
    def self.included(base)
      base.belongs_to :infocard
    end
  end
end