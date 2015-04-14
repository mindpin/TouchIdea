require 'rails_helper'

RSpec.describe Infocard, type: :model do
  describe "parse url" do
    it {
      url = "http://item.jd.com/1082403.html"
      infocard = Infocard.parse(url)
      infocard.title.should == "飞利浦(Philips) HP4589/05 负离子造型梳 秋冬护发必备呵护头发防静电,红黑个性潮流新色"
      infocard.price.should == "159.00"
      # @message.read!.should == true
      # @message.read?.should == true
    }
  end
end