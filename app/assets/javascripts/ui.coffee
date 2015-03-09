jQuery(document).on 'ready page:load', ->
  jQuery(document).delegate '.flash-message a.close', 'click', (evt)->
    jQuery(this).closest('.flash-message').hide(300)

jQuery(document).on 'ready page:load', ->
  jQuery(document).delegate 'form a.submit', 'click', (evt)->
    jQuery(this).closest('form').submit()