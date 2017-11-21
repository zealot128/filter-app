//= require jquery.tablesorter.min
//= require_self
//

$(document).ready(function() {
  $('.js-tablesorter').each(function() {
    $(this).tablesorter({
    	dateFormat : "ddmmyyyy"
    });
  });
});
