$(document).ready ->
  $(".answer-result").click ->
    $("#modal-" + $(this).data('id')).modal('show')
