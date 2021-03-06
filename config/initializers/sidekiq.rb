Sidekiq.configure_server do |config|
  config.options[:queues] = %w{touch_idea_indexer}
  config.redis = {url: "redis://localhost:6379"}
end

Sidekiq.configure_client do |config|
  config.redis = {url: "redis://localhost:6379"}
end