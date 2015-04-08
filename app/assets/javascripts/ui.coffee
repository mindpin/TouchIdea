# 用到了 turbolinks
# 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

jQuery(document).on 'ready page:load', ->
  console.debug 'loaded'

# 点亮 navbar
jQuery(document).on 'ready page:load', ->
  nav = jQuery('[data-nav]').data('nav')
  jQuery(".layout-footer a.item.#{nav}").addClass('active')

# 填充标题
jQuery(document).on 'ready page:load', ->
  title = jQuery('[data-title]').data('title')
  jQuery(".layout-header .page").text title

# home 页页签
jQuery(document).delegate '.page-landing .filter a.item', 'click', ->
  $item = jQuery(this)
  $item.closest('.filter').find('a.item').removeClass('active')
  $item.addClass('active')

# back 按钮链接
jQuery(document).on 'ready page:load', ->
  back_url = jQuery('[data-back]').data('back')
  jQuery(".layout-header .back").attr 'href', back_url

# 投票选项点击
jQuery(document).delegate '.topic-options .option', 'click', ->
  jQuery(this).toggleClass 'active'

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
    @$el.off 'click'
    @$el.on 'click', 'a.next:not(.disabled)', => @to_next()
    @$el.on 'click', 'a.prev:not(.disabled)', => @to_prev()
    @$el.on 'click', 'a.done.disabled', (evt)->
      evt.preventDefault()

    @$el.on 'click', 'a.additem', =>
      $input = @$el.find('.item-inputs .ipt').last().clone().val('')
      @$el.find('.item-inputs').append $input.hide().fadeIn(200)
      @refresh_item_ipts()

    that = this
    @$el.on 'click', '.ipt a.delete', ->
      return if jQuery(this).hasClass('disabled')
      jQuery(this).closest('.ipt').remove()
      that.refresh_item_ipts()

    # 如果成功读取了 infocard, 就把这些信息放到下一步表单中
    @$el.on 'click', 'a.next.urldone:not(.disabled)', =>
      @$infocard1 = @$infocard.clone()
      console.debug @$infocard1
      @$el.find('.part.tdesc')
        .find('.infocard').remove().end()
        .prepend @$infocard1

    # -------------

    @$url_textarea.off('input').on 'input' , =>
      if jQuery.trim(@$url_textarea.val()).length > 0
        @$a_loadurl.removeClass('disabled')
      else
        @$a_loadurl.addClass('disabled')

    # 议题描述校验
    @$tdesc_textarea.off('input').on 'input' , =>
      if jQuery.trim(@$tdesc_textarea.val()).length > 0
        @$tdesc_textarea.closest('.part').find('a.next').removeClass('disabled')
      else
        @$tdesc_textarea.closest('.part').find('a.next').addClass('disabled')

    @$el.find('.item-inputs').off('input').on 'input', =>
      @refresh_item_ipts()

    @$a_loadurl.off('click').on 'click', =>
      return if @$a_loadurl.hasClass('disabled')
      @loadurl()

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
        @$infocard.show(200)
        @$loading.hide()
        @$loadsuccess.show()
        @$el.find('a.next.skip').hide()
        @$el.find('a.next.urldone').show()



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


# 导航上的“新增”按钮
jQuery(document).delegate '.footer-nav .item.new', 'click', ->
  jQuery('.footer-nav').addClass('new-topic-type-select')
  jQuery('.float-new-type-select').addClass('show')

jQuery(document).delegate '.footer-nav a.cancel-new', 'click', ->
  jQuery('.footer-nav').removeClass('new-topic-type-select')
  jQuery('.float-new-type-select').removeClass('show')
