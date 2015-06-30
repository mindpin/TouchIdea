# 用到了 turbolinks
# 事件加载参考
# https://github.com/rails/turbolinks/#no-jquery-or-any-other-library

# 填充标题
jQuery(document).on 'ready page:load', ->
  FastClick.attach document.body
  
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
  if jQuery(this).is_val_empty()
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