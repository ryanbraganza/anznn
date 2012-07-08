$(function() {
  $('.hiddenmulti').hide();

  $('.add_multi_link').live('click', function() {
    var parent_div = $(this).parent();
    var my_multi_name = parent_div.attr('data-multi_name');
    var my_group_number = parseInt(parent_div.attr('data-group_number'));
    var next_group = my_group_number + 1;

    //show the next group of answers for the multi question
    parent_div.parent().find('div[data-group_number="' + next_group + '"]').show();
    $(this).hide();
    return false;
  });

});