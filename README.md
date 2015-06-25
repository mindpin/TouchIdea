Touch Idea
===========

## 准备工作
### 系统需要安装工具
**elasticsearch**

### 第一次运行，请执行以下指令
```
bundle install
cp config/mongoid.example.yml config/mongoid.yml
cp config/application.example.yml config/application.yml
```

然后打开**config/application.yml**，设置新浪微博相关内容

## 运行
### 其他需要运行工具
**elasticsearch**，不运行搜索页面会报错

ElasticSearch 安装说明：<br/>
https://github.com/mindpin/tech-exp/issues/89

第一次运行需创建索引：<br/>
```
rake elasticsearch:import
# 这个命令也可以在有索引时重建索引
```

### 测试环境直接执行
```
rails s
```
既可通过**http://localhost:3000**访问

但是由于新浪api需要验证域名，可以通过修改hosts来满足域名限制的要求