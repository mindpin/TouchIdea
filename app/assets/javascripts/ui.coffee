# 点击完成，提交表单
jQuery(document).on 'ready page:load', ->
  $('a.done').click ->
    $('#new_vote').submit()

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

# 投票选项点击
jQuery(document).on 'click', '.topic-options .option', ->
  jQuery(this).toggleClass 'active'

# ----------------------------

# 导航上的“新增”按钮
jQuery(document).on 'click', '.footer-nav .item.new', ->
  jQuery('.footer-nav').addClass('new-topic-type-select')
  jQuery('.float-new-type-select').addClass('show')

jQuery(document).on 'click', '.footer-nav a.cancel-new', ->
  jQuery('.footer-nav').removeClass('new-topic-type-select')
  jQuery('.float-new-type-select').removeClass('show')

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
  new TopicForm jQuery('.page-new-topic')
