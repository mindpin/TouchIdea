# 用到了 turbolinks
# 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

# jquery 扩展
jQuery.fn.extend
  is_val_empty: ->
    this.trim_val().length is 0

  trim_val: ->
    jQuery.trim this.val()

# 投票页面
# =========================

@refresh_voted_options = ->
  if jQuery('.topic-options .option.active').length > 0
    jQuery('.vote-done a.done').removeClass('disabled')
  else
    jQuery('.vote-done a.done').addClass('disabled')

# 点击投票选项
jQuery(document).on 'click', '.topic-options .option', ->
  if jQuery(this).hasClass('tiny') and not jQuery(this).hasClass('active')
    jQuery('.topic-options .option.tiny').removeClass('active')

  jQuery(this).toggleClass 'active'
  refresh_voted_options()

# 点击“投完了”
jQuery(document)
  .on 'click', '.vote-done a.done:not(.disabled)', ->
    $topic = jQuery(this).closest('.page-topic')
    vote_id = $topic.data('id')
    vote_item_ids = []
    $topic.find('a.option.active').each ->
      vote_item_ids.push jQuery(this).data('id')

    jQuery.ajax
      url: "/votes/#{vote_id}/praise"
      type: 'POST'
      data:
        vote_item_ids: vote_item_ids
      success: ->
        Turbolinks.visit('/votes/done')
      error: ->
        alert '系统出错啦'


# 导航上的“新增”按钮
# =========================

# 点击新增
jQuery(document).on 'click', '.footer-nav .item.new', ->
  jQuery('.footer-nav').addClass('new-topic-type-select')
  jQuery('.float-new-type-select').addClass('show')

# 点击取消
jQuery(document).on 'click', '.footer-nav a.cancel-new', ->
  jQuery('.footer-nav').removeClass('new-topic-type-select')
  jQuery('.float-new-type-select').removeClass('show')


# 无限滚动分页
# =======================

class ScrollingList
  constructor: (@$el)->
    @$loading = @$el.find('.loading')
    @bind_events()
    @scroll_event()

  bind_events: ->
    @$el.on 'scroll', (evt)=> @scroll_event()

  scroll_event: ->
    # 计算底部区域是否进入屏幕
    bottom1 = @$loading.offset().top + @$loading.outerHeight(true)
    bottom2 = @$el.offset().top + @$el.outerHeight()
    # console.debug bottom1, bottom2
    # console.debug @$loading.offset().top, @$el.offset().top
    # console.debug @$loading.outerHeight(true), @$el.outerHeight()
    delta = bottom1 - bottom2
    # console.debug delta
    if delta < 70
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
        that = @
        $new_items = jQuery(res).find('.scrolling-list .list-item')

        @$loading.removeClass 'requesting'

        if $new_items.length
          $new_items.each ->
            $item = jQuery(this)
            that.$loading.before $item
          @$loading.data('page', page + 1)
          @scroll_event()
        else
          @$loading.addClass 'end'

jQuery(document).on 'ready page:load', ->
  if jQuery('.scrolling-list').length > 0
    new ScrollingList jQuery('.scrolling-list')