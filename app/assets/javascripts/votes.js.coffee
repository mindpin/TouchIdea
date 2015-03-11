$(document).on "ready page:change", ->
  $(".answer-result").click ->
    $("#modal-" + $(this).data('id')).modal('show')

jQuery(document).on 'ready page:load', ->
  jQuery('.vote-questions').on 'cocoon:after-insert', (evt, item)->
    item.hide().fadeIn()

  jQuery('.date_picker.vote_finish_at').datetimepicker({
    language: 'zh-CN',
    pickTime: false
  });