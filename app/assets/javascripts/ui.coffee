jQuery(document).on 'ready page:load', ->
  jQuery(document).delegate '.flash-message a.close', 'click', (evt)->
    jQuery(this).closest('.flash-message').hide(300)