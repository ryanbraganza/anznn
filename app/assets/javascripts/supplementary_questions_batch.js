$(function() {
  showHideSupplementary();

  $('#batch_file_survey_id').live('change', function(){
    showHideSupplementary();
  });
});

function showHideSupplementary() {
  $('.supplementary_group').hide();
  var selected_survey_id = $('#batch_file_survey_id').val();
  if(selected_survey_id) {
    var div_id = "#supplementary_" + selected_survey_id;
    $(div_id).show();
  }
}