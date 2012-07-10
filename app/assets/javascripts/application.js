// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// To add bootstrap js, see https://github.com/thomas-mcdonald/bootstrap-sass

//= require jquery
//= require jquery_ujs
//= require help_text
//= require section_navigation
//= require ie6
//= require show_hide_multi_questions
//= require supplementary_questions_batch

$(window).load(function () {
  $('.row div[class^="span"]:last-child').addClass('last-child');
});
