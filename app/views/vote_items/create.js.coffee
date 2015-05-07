console.log <%= @vote_item.valid? %>

text = '<%= j @vote_item.title %>'
$option = jQuery('.sample a.option').clone()

$option.find('.text').text text
$option.addClass('active')
$option.attr('data-id', '<%= @vote_item.id %>')
jQuery('.topic-options.normal')
  .css 'margin-top', ''
  .append $option

jQuery('.new-option-overlay').removeClass('show')
refresh_voted_options()

jQuery('.page-topic .topic-new-option a.new')
  .addClass('disabled')
  .find('i').hide().end()
  .find('span').text('已经补充过选项了')
