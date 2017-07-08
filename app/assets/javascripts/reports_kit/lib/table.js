ReportsKit.Table = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.table = $('<table />', { 'class': 'table table-striped table-hover' }).appendTo(self.el);
  };

  self.render = function() {
    var path = self.el.data('path') + 'reports_kit/reports';
    path += '?properties=' + JSON.stringify(self.report.properties());
    $.getJSON(path, function(response) {
      var data = response.data;
      var tableData = data.table_data;

      var html = '';
      for(var i = 0; i < tableData.length; i++) {
        html += '<tr>';
        for(var j = 0; j < tableData[i].length; j++) {
          if (i == 0 || j == 0) {
            html += '<th>' + (tableData[i][j] || '') + '</th>';
          } else {
            html += '<td>' + tableData[i][j] + '</td>';
          }
        }
        html += '</tr>';
      }
      self.table.html(html);
    });
  };

  self.initialize(options);

  return self;
});
