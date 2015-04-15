# 新建议题，点完成提交
jQuery(document).on 'ready page:load', ->
  $('.page-new-topic a.done').click ->
    $('#new_vote').submit()

