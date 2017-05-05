window.ReportsKit = {};

$(document).ready(function() {
  $('.reports_kit_report').each(function(index, el) {
    var el = $(el)
    new ReportsKit.Report({ 'el': el });
  });
});
