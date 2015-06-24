###
  投票页面的逻辑
###


# # 分享
# jQuery(document).on 'click', '.page-topic a.share', ->
#   jQuery('.share-overlay').addClass('show')

# jQuery(document).on 'click', '.share-overlay a.cancel', ->
#   jQuery('.share-overlay').removeClass('show')

class NewOptionPanel
  constructor: (@$elm)->
    @$overlay = @find('.new-option-overlay')

    @bind_events()

  find: (str)->
    @$elm.find(str)

  bind_events: ->
    # 打开对话框
    @$elm.on 'click', '.topic-new-option a.new:not(.disabled)', =>
      @$overlay.addClass('show')

    # 关闭对话框
    @$elm.on 'click', '.new-option-overlay a.cancel', =>
      @$overlay.removeClass('show')

    # 输入文字时激活确定按钮
    @$elm.on 'input', '.new-option-overlay textarea', =>
      if is_field_empty @$overlay.find('textarea')
        @$overlay.find('a.ok').addClass('disabled')
      else
        @$overlay.find('a.ok').removeClass('disabled')

    # 确定创建
    @$elm.on 'click', '.new-option-overlay a.ok:not(.disabled)', =>
      text = @$overlay.find('textarea').val()
      url = @$overlay.find('.form').data('url')
      jQuery.ajax
        url: url
        type: 'POST'
        data:
          vote_item:
            title: text
        success: (res)=>
          @created res

  created: (data)->
    $option = jQuery('.sample a.option').clone()
      .addClass 'active my-extra'
      .attr('data-id', data.vote_item.id)
      .find('.text').text(data.vote_item.title).end()

    @find('.topic-options.normal')
      .removeClass('blank')
      .append $option

    # 关闭对话框
    @$overlay.removeClass('show')
    
    # 刷新投完按钮
    @$elm.trigger 'refresh-done-btn'

    # 关闭补充选项按钮
    @find('.topic-new-option a.new').addClass('disabled')



class VoteShowPage
  constructor: (@$elm)->
    @$done_btn = @find('.vote-done a.done')

    @bind_events()

  find: (str)->
    @$elm.find(str)

  bind_events: ->
    # 跳到下一个
    @$elm.on 'click', 'a.next-vote', =>
      @jump_to_next()    

    # 刷新“投完了”按钮
    @$elm.on 'refresh-done-btn', => @refresh_done_btn()


    # 点击投票选项
    that = this
    @$elm.on 'click', '.topic-options .option', ->
      if jQuery(this).hasClass('tiny') and not jQuery(this).hasClass('active')
        that.find('.topic-options .option.tiny')
          .removeClass('active')

      jQuery(this).toggleClass 'active'
      that.refresh_done_btn()

    # 点击“投完了”
    @$elm.on 'click', '.vote-done a.done:not(.disabled)', =>
      @vote_done()


  jump_to_next: ->
    # 不保存历史记录
    location.replace '/votes/lucky'

  refresh_done_btn: ->
    if @find('.topic-options .option.active').length
      @$done_btn.removeClass('disabled')
    else
      @$done_btn.addClass('disabled')

  vote_done: ->
    vote_id = @$elm.data('id')
    vote_item_ids = for dom in @$elm.find('a.option.active')
      jQuery(dom).data('id')

    # console.log vote_id
    # console.log vote_item_ids

    jQuery.ajax
      url: "/votes/#{vote_id}/praise"
      type: 'POST'
      data:
        vote_item_ids: vote_item_ids
      success: =>
        # 不保存历史记录
        @jump_to_next()
      error: ->
        alert '系统出错啦'




jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body

  if jQuery('.page-topic').length
    new VoteShowPage jQuery('.page-topic')
    new NewOptionPanel jQuery('.page-topic')