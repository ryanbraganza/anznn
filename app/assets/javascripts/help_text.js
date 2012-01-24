// help_text.js

!function($){
  $(document).ready(function(){
    var $field_trigger = $('.field_trigger');
    var $field_info = $('#field_info');
    var initial_text = $field_info.text();

    $field_trigger.focus(function(){
      var field_info = $(this).data('fieldinfo');
      $field_info.text(field_info);
    });
    $field_trigger.blur(function(){
      $field_info.text(initial_text);
    });
  });
}(jQuery);
