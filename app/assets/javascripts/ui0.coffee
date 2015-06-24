# 用到了 turbolinks
# 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

# 填充标题
jQuery(document).on 'ready page:load', ->
  title = jQuery('[data-title]').data('title')
  jQuery(".layout-header .page").text title

# home 页页签
jQuery(document).on 'click', '.page-landing .filter a.item', ->
  $item = jQuery(this)
  $item.closest('.filter').find('a.item').removeClass('active')
  $item.addClass('active')

# back 按钮链接
jQuery(document).on 'ready page:load', ->
  back_url = jQuery('[data-back]').data('back')
  jQuery(".layout-header .back").attr 'href', back_url

# ---------------------------------

class SearchPage
  constructor: (@$el)->
    @$history = @$el.find('.history')
    @$result = @$el.find('.result')
    @$input = @$el.find('input[name=q]')
    @$topbar = @$el.find('.topbar')

    @bind_events()
    @insert_search_histroy_dom()

  bind_events: ->
    that = this

    # 删除搜索历史项
    @$el.on 'click', '.history .word a.delete', ->
      jQuery(this).closest('.word').fadeOut 200, ->
        query = jQuery(this).find('.t').text()
        that.remove_search_history(query)
        jQuery(this).remove()

    # 点选搜索历史项
    @$el.on 'click', '.history .word a.s', ->
      q = jQuery(this).find('.t').text()
      that.$input.val q
      that.search()

    # 取消搜索状态
    @$el.on 'click', '.topbar a.cancel', ->
      that.cancel()

    # 输入搜索词
    @$input.on 'input', =>
      input_cache = @$input.val()
      setTimeout =>
        if @$input.val() == input_cache
          @search()
      , 500

    # 清除搜索历史
    @$el.on 'click', '.history a.clear', =>
      if confirm '确定要清除吗？'
        @$el.find('.history .word').fadeOut 200, =>
          @$el.find('.history .word').remove()
          @remove_all_search_history()

    # 增加搜索历史
    @$el.on 'click', '.result .topic', ->
      query = jQuery.trim(that.$input.val())
      that.add_search_history(query)

  get_search_history: ->
    localStorage["search_history"] ||= JSON.stringify([])
    JSON.parse localStorage["search_history"]

  remove_all_search_history: (query)->
    search_history = @get_search_history()
    localStorage["search_history"] = JSON.stringify([])    

  remove_search_history: (query)->
    search_history = @get_search_history()
    search_history.splice(jQuery.inArray(query,search_history),1);
    localStorage["search_history"] = JSON.stringify(search_history)

  add_search_history: (query)->
    search_history = @get_search_history()
    # query_is_add = false
    # search_history = jQuery.map search_history, (h)=>
    #   if h.indexOf(query) == 0
    #     query_is_add = true
    #     return h
    #   else if query.indexOf(h) == 0
    #     query_is_add = true
    #     return query
    #   return h
    # if !query_is_add
    #   search_history.push query
    if -1 == jQuery.inArray(query, search_history)
      search_history.push query
      localStorage["search_history"] = JSON.stringify(search_history)

  insert_search_histroy_dom: ->
    doms = jQuery.map @get_search_history(), (query)=>
      "
        <div class='word'>
          <a class='s' href='javascript:;'>
            <i class='fa fa-clock-o'></i>
            <div class='t'>#{query}</div>
          </a>
          <a class='delete' href='javascript:;'>
            <i class='fa fa-times'></i>
          </a>
        </div>
      "
    @$history.find(".word").remove()
    @$history.find('.clear').before(doms.join(""))

  insert_result_dom: (votes)->
    doms = jQuery.map votes, (vote)=>
      "
        <a class='topic' href='/votes/#{vote.id}'>
          <div class='data'>
            <div class='title'>#{vote.title}</div>
            <div class='stat'>
              <span>#{vote.vote_items_count} 个选项</span>
              <span>#{vote.voted_users_count} 人参与</span>
            </div>
          </div>
          <div class='joiner-count'>#{vote.voted_users_count}</div>
        </a>
      "
    @$result.find('.topic').remove()
    @$result.append(doms.join(""))


  search: ->
    query = jQuery.trim(@$input.val())
    @$topbar.addClass 'filled'
    if not is_field_empty @$input
      @$history.hide()
      jQuery.ajax
        url: '/votes/search.json'
        method: 'GET'
        data:
          q: query
        success: (res)=>
          @insert_result_dom(res)
          @$result.fadeIn(200)
    else
      @insert_search_histroy_dom()
      @$history.fadeIn 200
      @$result.hide()

  cancel: ->
    @$history.fadeIn 200
    @$result.hide()
    @$input.val ''
    @$topbar.removeClass 'filled'


jQuery(document).on 'ready page:load', ->
  if jQuery('.page-search').length > 0
    new SearchPage jQuery('.page-search')

# 登出
jQuery(document).on 'click', '.page-me a.quit', ->
  if confirm('确定要退出吗？')
    jQuery.ajax
      url: '/users/sign_out'
      method: 'DELETE'

# 点击设置项
jQuery(document).on 'click', '.page-me a.toggler', ->
  jQuery(this).toggleClass('on')
  jQuery(this).toggleClass('off')
  if jQuery(this).hasClass('on')
    jQuery.ajax
      method: 'PUT'
      url: '/notification_setting'
      data:
        key: jQuery(this).data('key')
        value: true
  if jQuery(this).hasClass('off')
    jQuery.ajax
      method: 'PUT'
      url: '/notification_setting'
      data:
        key: jQuery(this).data('key')
        value: false

# 输入反馈
jQuery(document).on 'input', 'textarea.feedback-ipt', ->
  if is_field_empty jQuery(this)
    jQuery(this).next('a.btn').addClass('disabled')
  else
    jQuery(this).next('a.btn').removeClass('disabled')

# 提交反馈
jQuery(document).on 'click', 'a.submit-feedback:not(.disabled)', ->
  jQuery('.feedback .form').hide()
  jQuery('.feedback .success').fadeIn()
  jQuery.ajax
    url: '/feedbacks'
    method: 'POST'
    data:
      content: jQuery.trim(jQuery('textarea.feedback-ipt').val())