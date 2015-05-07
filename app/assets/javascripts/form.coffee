# 表单页的各种事件
class TopicForm
  constructor: (@$el)->
    return if @$el.length is 0
    @current_step = 1

    @$url_textarea = @$el.find('textarea.url')
    @$a_loadurl = @$el.find('a.loadurl')

    @$loading = @$el.find('.loading')
    @$loadsuccess = @$el.find('.loaded-success')
    @$loadfailure = @$el.find('.loaded-failure')

    @$tdesc_textarea = @$el.find('textarea.tdesc')

    @bind_events()

  bind_events: ->
    # 上一步，下一步，完成
    @$el.on 'click', 'a.next:not(.disabled)', => @to_next()
    @$el.on 'click', 'a.prev:not(.disabled)', => @to_prev()
    # 提交表单
    @$el.on 'click', 'a.done:not(.disabled)', =>
      @$el.find('form').submit()

    that = this

    # 增加选项
    @$el.on 'click', 'a.additem', =>
      $ipt = @$el.find('.sample .ipt').last().clone()
      $ipt.find('input').val('').attr('disabled', false)
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
      if @$url_textarea.is_val_empty()
        @$a_loadurl.addClass('disabled')
      else
        @$a_loadurl.removeClass('disabled')

    # 读取网址
    @$a_loadurl.on 'click', =>
      return if @$a_loadurl.hasClass('disabled')
      @loadurl()

    # 如果成功读取了网址信息, 就把这些信息放到下一步表单中
    @$el.on 'click', 'a.next.urldone:not(.disabled)', =>
      $infocard = jQuery('.part.topenurl .infocard').clone()
      @$el.find('.part.tdesc')
        .find('.infocard').remove().end()
        .prepend $infocard
        .find('textarea').val('这是我的购物分享，说说你的看法吧！').end()
        .find('a.next').removeClass('disabled')

    # -----------

    # 议题描述校验
    @$tdesc_textarea.on 'input' , =>
      $a_next = @$tdesc_textarea.closest('.part').find('a.next')
      if @$tdesc_textarea.is_val_empty()
        $a_next.addClass('disabled')
      else
        $a_next.removeClass('disabled')


  refresh_item_ipts: ->
    limit = @$el.find('.item-inputs').data('limit')
    count = 0
    @$el.find('.item-inputs input').each (idx, i)->
      jQuery(this).attr('placeholder', "选项 #{idx + 1}")
      if not jQuery(this).is_val_empty()
        count += 1

      if count >= limit
        jQuery(this).closest('.part').find('a.done').removeClass('disabled')
      else
        jQuery(this).closest('.part').find('a.done').addClass('disabled')

    if @$el.find('.item-inputs input').length <= limit
      @$el.find('.item-inputs .ipt a.delete').addClass('disabled')
    else
      @$el.find('.item-inputs .ipt a.delete').removeClass('disabled')

  loadurl: ->
    ## 显示读取进度条（伪进度条）
    @$a_loadurl.hide()
    @$loading.show()
    @$loadfailure.hide()
    @$loadsuccess.hide()
    $skip = @$el.find('a.next.skip')
    $p = @$loading.find('.p')

    $skip.addClass('disabled')
    $p
      .css
        'width': 0
      .animate
        'width': '90%'
      , 3000 , 'linear'

    ## 读取 infocard 信息 开始
    url = @$url_textarea.trim_val()
    request_url = @$a_loadurl.data('url')

    jQuery.ajax
      url: request_url
      method: 'GET'
      data:
        url: url
      success: (res)=>
        $p.stop().animate
          'width': '100%'
        , 300, 'linear', =>
          @$loading.hide()
          @$loadsuccess.show()
          @$el.find('a.next.skip').hide()
          @$el.find('a.next.urldone').show()
          @$url_textarea.attr('disabled', true)

          $html = jQuery(res.html).hide().fadeIn()
          jQuery('.part.topenurl')
            .find('.infocard').remove().end()
            .append $html.addClass('shopping')

          jQuery('input.url-infocard').val res.id

      error: (res)=>
        $p.stop().animate
          'width': '0'
        , 200, 'linear', =>
          @$a_loadurl.show()
          @$loading.hide()
          @$loadfailure.fadeIn()
          $skip.removeClass('disabled')


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

      # 选项页面判断是否购物分享类
      if $to_part.hasClass('titems')
        if $current_part.find('.infocard.shopping').length
          # 是商品分享，特殊处理
          # 1. 开启系统默认三选项
          $to_part
            .find('.fields.default-items').show()
            .find('input').attr('disabled', false)
          # 2. 修改预置选项表单
          $to_part
            .find('label.add-item').text '你还可以添加更多选项'
          $to_part
            .find('.item-inputs').data('limit', 0)
            .find('.ipt').remove()
          $to_part
            .find('a.done').removeClass('disabled')


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