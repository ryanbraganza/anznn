function show_message(message_class) {
  if (message_class.length > 0) {
    message_class.slideDown();

    var alerttimer = window.setTimeout(function () {
      message_class.slideUp();
    }, 9000);
    $(".alert").click(function () {
      window.clearTimeout(alerttimer);
      message_class.slideUp();
    });
  }
}
$(window).load(function() {

  $(function () {
    var alert = $('.alert');
    var notice = $('.notice');
    show_message(alert);
    show_message(notice);
  });

});

