namespace "elasticsearch" do
  desc "创建搜索索引"
  task import: :environment do

    [Vote].each do |model|
       puts "====: 开始导入 #{model.to_s} 的索引"
       model.import :force => true
       puts "====: 导入完毕."
     end
    p "索引创建完成"
  end

end
