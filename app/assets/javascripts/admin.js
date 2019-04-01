//= require jquery.tablesorter.min
//= require_self
//

$(document).ready(function() {
  console.log( "ready!" );
  $('.js-tablesorter').each(function() {
    $(this).tablesorter({
    	dateFormat : "ddmmyyyy"
    });
  });
});
