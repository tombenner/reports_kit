ReportsKit.Table = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.loadingIndicatorEl = $('<div class="loading_indicator"></div>').appendTo(self.report.visualizationEl).hide();
    self.table = $('<table />', { 'class': 'table table-striped table-hover' }).appendTo(self.report.visualizationEl);
  };

  self.render = function() {
    var path = self.el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + encodeURIComponent(JSON.stringify(self.report.properties()));
    self.loadingIndicatorEl.fadeIn(100);
    $.getJSON(path, function(response) {
      var data = response.data;
      var tableData = data.table_data;

      self.loadingIndicatorEl.stop(true, true).hide();

      var html = '';
      for(var i = 0; i < tableData.length; i++) {
        if (i == 0) {
          html += '<thead><tr>';
        } else if (i == 1) {
          html += '<tbody><tr>';
        } else {
          html += '<tr>';
        }

        for(var j = 0; j < tableData[i].length; j++) {
          if (i == 0 || j == 0) {
            html += '<th>' + (tableData[i][j] || '') + '</th>';
          } else {
            html += '<td>' + tableData[i][j] + '</td>';
          }
        }

        if (i == 0) {
          html += '</tr></thead>';
        } else if (i == tableData.length) {
          html += '</tr></tbody>';
        } else {
          html += '</tr>';
        }
      }
      self.table.html(html);
      self.table.tablesorter();
    });
  };

  self.initialize(options);

  return self;
});
