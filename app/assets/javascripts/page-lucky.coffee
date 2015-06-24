class LuckyPage
  constructor: (@$elm)->
    # jQuery('.layout-footer').hide()

    @load_next()

  find: (str)->
    @$elm.find(str)

  load_next: ->
    jQuery.ajax
      url: '/votes/lucky'
      success: (res)->
        id = res.id
        # 不保存历史记录
        path = "/votes/#{id}"
        Turbolinks.visit_without_history path
      statusCode: {
        404: =>
          setTimeout =>
            @$elm.addClass 'end'
          , 500
      }



jQuery(document).on 'ready page:load', ->
  if jQuery('.page-lucky').length
    new LuckyPage jQuery('.page-lucky')