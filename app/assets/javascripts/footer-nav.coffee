# # 导航上的“新增”按钮
# # =========================

# # 点亮 footer navbar
# jQuery(document).on 'ready page:load', ->
#   nav = jQuery('[data-nav]').data('nav')
#   jQuery(".layout-footer a.item.#{nav}").addClass('active')

class FooterNav
  constructor: (@$elm)->
    @$new_panel = jQuery('.float-new-type-select')

    @bind_events()

  find: (str)->
    @$elm.find(str)

  bind_events: ->
    # 点击新增
    @$elm.on 'click', '.footer-nav .item.new', =>
      @find('.footer-nav').addClass('new-topic-type-select')
      @$new_panel.addClass('show')

    # 取消新增
    @$elm.on 'click', '.footer-nav a.cancel-new', =>
      @find('.footer-nav').removeClass('new-topic-type-select')
      @$new_panel.removeClass('show')

    # 访问页签
    that = this
    @$elm.on 'click', '.footer-nav a.item[data-url]', ->
      that.find('.footer-nav a.item').removeClass('active')
      # jQuery(this).addClass 'active'
      url = jQuery(this).data('url')
      Turbolinks.visit_without_history url#, {keep: 'footer-nav'}


jQuery(document).on 'page:change', ->
  if jQuery('.layout-footer').length
    new FooterNav jQuery('.layout-footer')