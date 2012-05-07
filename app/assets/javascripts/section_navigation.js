// section_navigation.js
// On-click hooks for the section navigation links. Each link sets a hidden field indicating where to go next, then submits the form
$(function() {
  $('a.section-navigation').live('click', function() {
    var section_id = $(this).attr('section_id');
    $('#go_to_section_field').val(section_id);
    $('#response_form').submit();
    return false;
  });
});