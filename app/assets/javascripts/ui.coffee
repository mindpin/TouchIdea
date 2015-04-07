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

# 表单页的下一步按钮
jQuery(document).delegate '.page-new-topic .form a.next', 'click', ->
  $current_part = jQuery(this).closest('.part')
  $to_part = $current_part.next('.part')

  current = $current_part.data('step')
  to = $to_part.data('step')

  $current_part.fadeOut(200)
  $to_part.fadeIn(200)

  jQuery(".topbar .steps .step[data-step=#{current}]")
    .removeClass('active')
    .addClass('done')

  jQuery(".topbar .steps .step[data-step=#{to}]")
    .addClass('active')

jQuery(document).delegate '.page-new-topic .form a.prev', 'click', ->
  $current_part = jQuery(this).closest('.part')
  $to_part = $current_part.prev('.part')

  current = $current_part.data('step')
  to = $to_part.data('step')

  $current_part.fadeOut(200)
  $to_part.fadeIn(200)

  jQuery(".topbar .steps .step[data-step=#{current}]")
    .removeClass('active')

  jQuery(".topbar .steps .step[data-step=#{to}]")
    .removeClass('done')
    .addClass('active')
