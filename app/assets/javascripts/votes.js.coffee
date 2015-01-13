$(document).on "ready page:change", ->
  $(".answer-result").click ->
    $("#modal-" + $(this).data('id')).modal('show')
