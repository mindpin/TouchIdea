# 用到了 turbolinks
# 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

# 事件检查
jQuery(document).on 'ready page:load', ->
  console.debug 'loaded'

# 点亮 footer navbar
jQuery(document).on 'ready page:load', ->
  nav = jQuery('[data-nav]').data('nav')
  jQuery(".layout-footer a.item.#{nav}").addClass('active')

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

is_field_empty = ($field)->
  return jQuery.trim($field.val()).length is 0

# 表单页的各种事件
class TopicForm
  constructor: (@$el)->
    return if @$el.length is 0
    @current_step = 1

    @$url_textarea = @$el.find('textarea.url')
    @$a_loadurl = @$el.find('a.loadurl')
    @$infocard = @$el.find('.infocard')
    @$loading = @$el.find('.loading')
    @$loadsuccess = @$el.find('.loaded-success')

    @$tdesc_textarea = @$el.find('textarea.tdesc')

    @bind_events()

  bind_events: ->
    # 上一步，下一步，完成
    @$el.on 'click', 'a.next:not(.disabled)', => @to_next()
    @$el.on 'click', 'a.prev:not(.disabled)', => @to_prev()
    @$el.on 'click', 'a.done.disabled', (evt)->
      evt.preventDefault()

    that = this

    # 增加选项
    @$el.on 'click', 'a.additem', =>
      $ipt = @$el.find('.item-inputs .ipt').last().clone()
      $ipt.find('input').val('')
      $ipt.hide().fadeIn(200)
      @$el.find('.item-inputs').append $ipt
      @refresh_item_ipts()

    # 移除选项
    @$el.on 'click', '.ipt a.delete:not(.disabled)', ->
      jQuery(this).closest('.ipt').remove()
      that.refresh_item_ipts()

    # 当输入选项时进行校验
    @$el.find('.item-inputs').on 'input', =>
      @refresh_item_ipts()

    # ----------

    # 输入网址后才点亮读取按钮
    @$url_textarea.on 'input' , =>
      if is_field_empty @$url_textarea
        @$a_loadurl.addClass('disabled')
      else
        @$a_loadurl.removeClass('disabled')

    # 读取网址
    @$a_loadurl.on 'click', =>
      return if @$a_loadurl.hasClass('disabled')
      @loadurl()

    # 如果成功读取了网址信息, 就把这些信息放到下一步表单中
    @$el.on 'click', 'a.next.urldone:not(.disabled)', =>
      @$el.find('.part.tdesc')
        .find('.infocard').remove().end()
        .prepend @$infocard.clone()

    # -----------

    # 议题描述校验
    @$tdesc_textarea.on 'input' , =>
      $a_next = @$tdesc_textarea.closest('.part').find('a.next')
      if is_field_empty @$tdesc_textarea
        $a_next.addClass('disabled')
      else
        $a_next.removeClass('disabled')


  refresh_item_ipts: ->
    count = 0
    @$el.find('.item-inputs input').each (idx, i)->
      jQuery(this).attr('placeholder', "选项 #{idx + 1}")
      if jQuery.trim(jQuery(this).val()).length > 0
        count += 1
      if count >= 2
        jQuery(this).closest('.part').find('a.done').removeClass('disabled')
      else
        jQuery(this).closest('.part').find('a.done').addClass('disabled')

    if @$el.find('.item-inputs input').length < 3
      @$el.find('.item-inputs .ipt a.delete').addClass('disabled')
    else
      @$el.find('.item-inputs .ipt a.delete').removeClass('disabled')

  loadurl: ->
    ## 读取 infocard 信息 开始
    url = jQuery.trim(@$url_textarea.val())
    jQuery.ajax
      url: "/infocards"
      method: "POST"
      data:
        url: url
      success: (res)=>
        @$infocard.find(".product-logo img").attr("src", res.pictures[0])
        @$infocard.find(".data .product-name").text(res.title)
        @$infocard.find(".data .product-price").text(res.price)
        jQuery("<input name='vote[infocard_id]' value='#{res.id}' type='hidden'/>").appendTo(@$infocard)

    ## 读取 infocard 信息 结束
    @$a_loadurl.hide()
    @$loading.show()
    @$el.find('a.next.skip').addClass('disabled')
    @$loading.find('.p')
      .css
        'width': 0
      .animate
        'width': '100%'
      , 3000, =>
        @$infocard.fadeIn(200)
        @$loading.hide()
        @$loadsuccess.show()
        @$el.find('a.next.skip').hide()
        @$el.find('a.next.urldone').show()
        @$url_textarea.attr('disabled', true)

  to_next: ->
    to_step = @current_step + 1
    $current_link = @$el.find(".steps .step[data-step=#{@current_step}]")
    $to_link = @$el.find(".steps .step[data-step=#{to_step}]")

    if $to_link.length > 0
      $current_part = @$el.find(".part[data-step=#{@current_step}]")
      $to_part = @$el.find(".part[data-step=#{to_step}]")

      $current_part.fadeOut(200)
      $to_part.fadeIn(200)
      $current_link.removeClass('active').addClass('done')
      $to_link.addClass('active')

      @current_step = to_step

  to_prev: ->
    to_step = @current_step - 1
    $current_link = @$el.find(".steps .step[data-step=#{@current_step}]")
    $to_link = @$el.find(".steps .step[data-step=#{to_step}]")

    if $to_link.length > 0
      $current_part = @$el.find(".part[data-step=#{@current_step}]")
      $to_part = @$el.find(".part[data-step=#{to_step}]")

      $current_part.fadeOut(200)
      $to_part.fadeIn(200)
      $current_link.removeClass('active')
      $to_link.addClass('active').removeClass('done')

      @current_step = to_step


jQuery(document).on 'ready page:load', ->
  if jQuery('.page-new-topic').length > 0
    new TopicForm jQuery('.page-new-topic')

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
    jQuery(document).on 'click', '.page-search .result .topic', ->
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

# ------------

# 在选项详情界面增加选项
jQuery(document).on 'click', '.page-topic .topic-new-option a.new:not(.disabled)', ->
  console.debug jQuery('.new-option-overlay')
  jQuery('.new-option-overlay').addClass('show')

jQuery(document).on 'click', '.new-option-overlay a.cancel', ->
  jQuery('.new-option-overlay').removeClass('show')

jQuery(document).on 'click', '.new-option-overlay a.ok:not(.disabled)', ->
  $('#new_vote_item').submit()
  # 移至vote_items/create.js.coffee

jQuery(document).on 'input', '.new-option-overlay textarea', ->
  if is_field_empty jQuery('.new-option-overlay textarea')
    jQuery('.new-option-overlay a.ok').addClass('disabled')
  else
    jQuery('.new-option-overlay a.ok').removeClass('disabled')

# 分享
jQuery(document).on 'click', '.page-topic a.share', ->
  jQuery('.share-overlay').addClass('show')

jQuery(document).on 'click', '.share-overlay a.cancel', ->
  jQuery('.share-overlay').removeClass('show')

# ----------

@refresh_voted_options = ->
  if jQuery('.topic-options .option.active').length > 0
    jQuery('.vote-done a.done').removeClass('disabled')
  else
    jQuery('.vote-done a.done').addClass('disabled')


# 完成投票，加载下一个
jQuery(document).on 'ready page:load', ->
  if jQuery('.page-vote-done').length
    setTimeout ->
      Turbolinks.visit('/votes/lucky')
    , 1000