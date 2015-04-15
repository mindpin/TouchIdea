console.log <%= @vote_item.valid? %>
text = '<%= j @vote_item.title %>'
$option = jQuery('a.option').first().clone()
$option.find('.text').text text
$option.addClass('active')
$option.attr('data-vote_item_id', '<%= @vote_item.id %>')
jQuery('.topic-options').append $option
jQuery('.new-option-overlay').removeClass('show')
refresh_voted_options()

jQuery('.page-topic .topic-new-option a.new')
  .addClass('disabled')
  .find('i').hide().end()
  .find('span').text('只能补充一个，已经补充过了')
