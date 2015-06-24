# jquery 扩展
jQuery.fn.extend
  is_val_empty: ->
    this.trim_val().length is 0

  trim_val: ->
    jQuery.trim this.val()

# 改变页面路径，并且不保留历史记录
Turbolinks.visit_without_history = (path, options = {})->
  # location.replace path
  window.history.replaceState window.history.state, '', path
  Turbolinks.visit path, options