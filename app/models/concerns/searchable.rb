module Searchable
  extend ActiveSupport::Concern 

  included do
    include Elasticsearch::Model

    __elasticsearch__.client = Elasticsearch::Client.new host: "http://localhost:9200", log: true

    Searchable.enabled_models.add(self)

  end

  def self.enabled_models
    @_enabled_models ||= Set.new
  end

  def as_indexed_json(options={})
    as_json(only: [:title])
  end

  module ClassMethods
    def custom_analysis
      {
        :analyzer => {
          :chargram => {
            :type => :custom,
            :tokenizer => :chargram,
            :filter => [:lowercase]
          }
        },

        :tokenizer => {
          :chargram => {
            :type => :edgeNGram,
            :min_gram => 1,
            :max_gram => 128,
            :token_chars => [:letter, :digit],
            :side => :front
          }
        }
      }
    end
  end
end
