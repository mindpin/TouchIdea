module VoteSearchConfig
  extend ActiveSupport::Concern 

  included do
    include Searchable

    settings :index => {:number_of_shards => 1}, :analysis => custom_analysis do
      mappings :dynamic => "false" do
        indexes :title, :analyzer => :chargram
      end
    end
  end

  def as_indexed_json(options={})
    as_json(only: [:title])
  end

  module ClassMethods
    def page_search(query,page = 1, per = 20)
      page = 1 if page.blank?
      param = {
        :from => page-1,
        :size => per,
        :query => {
          :multi_match => {
            :type  => :best_fields, 
            :query => query,
            :fields => [:title]
          }
        },

        :highlight => {
          :pre_tags => ["<em class='highlight'>"],
          :post_tags => ["</em>"],
          :fields => {:title=>{}}
        }
      }

      Vote.search(param)
    end

  end

end