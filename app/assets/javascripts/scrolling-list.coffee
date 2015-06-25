# 无限滚动分页

class ScrollingList
  constructor: (@$elm)->
    @$loading = @find('.loading')

    @bind_events()
    @scroll_event()

  find: (str)->
    @$elm.find(str)

  bind_events: ->
    @$elm.on 'scroll', (evt)=> @scroll_event()

  scroll_event: ->
    # 计算底部区域是否进入屏幕
    bottom1 = @$loading.offset().top + @$loading.outerHeight(true)
    bottom2 = @$elm.offset().top + @$elm.outerHeight()
    # console.debug bottom1, bottom2
    # console.debug @$loading.offset().top, @$elm.offset().top
    # console.debug @$loading.outerHeight(), @$elm.outerHeight()
    delta = bottom1 - bottom2
    # console.debug delta
    if delta < 50
      @load_next_page()

  load_next_page: ->
    return if @$loading.hasClass 'end'
    return if @$loading.hasClass 'requesting'

    @$loading.addClass 'requesting'
    url = @$loading.data('url')
    page = @$loading.data('page') or 1

    console.debug 'load next page'
    jQuery.ajax
      url: url
      type: 'GET'
      data: 
        page: page + 1
      success: (res)=>
        $new_items = jQuery(res).find('.scrolling-list .list-item')

        @$loading.removeClass 'requesting'

        if $new_items.length
          for item in $new_items
            $item = jQuery(item)
            @$loading.before $item
          @$loading.data('page', page + 1)
          @scroll_event()
        else
          @$loading.addClass 'end'

###
.page-xxx

  .scrolling-list
    .list-item
    .list-item

    .loading{:data => {:url => '...'}}
###

jQuery(document).on 'page:change', ->
  if jQuery('.scrolling-list').length > 0
    new ScrollingList jQuery('.scrolling-list')