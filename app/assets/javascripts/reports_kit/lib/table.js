ReportsKit.Table = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.defaultEmptyStateText = 'No data was found';
    self.emptyStateEl = $('<div>' + self.defaultEmptyStateText + '</div>').appendTo(self.report.visualizationEl).hide();
    self.loadingIndicatorEl = $('<div class="loading_indicator"></div>').appendTo(self.report.visualizationEl).hide();
    self.table = $('<table />', { 'class': 'table table-striped table-hover' }).appendTo(self.report.visualizationEl);
  };

  self.render = function() {
    var path = self.el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + encodeURIComponent(JSON.stringify(self.report.properties()));
    self.loadingIndicatorEl.fadeIn(1000);
    if (self.table.is(':visible')) {
      self.table.fadeTo(300, 0.1);
    }
    $.getJSON(path, function(response) {
      var data = response.data;
      var tableData = data.table_data;
      var reportOptions = data.report_options || {};
      // If the data only includes column headers, then it we have an empty state.
      var isEmptyState = tableData.length <= 1;
      var emptyStateText = reportOptions.empty_state_text || self.defaultEmptyStateText;
      self.emptyStateEl.html(emptyStateText);

      self.loadingIndicatorEl.stop(true, true).hide();
      self.emptyStateEl.toggle(isEmptyState);
      if (isEmptyState) {
        self.table.hide();
        return;
      }
      self.table.show().fadeTo(300, 1);

      var rowsCount = tableData.length;

      var hasHead = typeof reportOptions.head_rows_count !== 'undefined';
      var hasFoot = typeof reportOptions.foot_rows_count !== 'undefined';
      var headRowStartIndex = hasHead ? 0 : 0;
      var headRowEndIndex = hasHead ? reportOptions.head_rows_count - 1 : 0;
      var footRowStartIndex = hasFoot ? rowsCount - reportOptions.foot_rows_count : null;
      var footRowEndIndex = hasFoot ? rowsCount - 1 : null;

      var html = '';
      for(var i = 0; i < rowsCount; i++) {
        if (i === headRowStartIndex) {
          html += '<thead><tr>';
        } else if (i === (headRowEndIndex + 1)) {
          html += '<tbody><tr>';
        } else if (i === footRowStartIndex) {
          html += '<tfoot><tr>';
        } else {
          html += '<tr>';
        }

        for(var j = 0; j < tableData[i].length; j++) {
          if (i == 0 || j == 0) {
            html += '<th>' + (tableData[i][j] || '') + '</th>';
          } else {
            html += '<td>' + ((tableData[i][j] === null) ? '' : tableData[i][j]) + '</td>';
          }
        }

        if (i === headRowEndIndex) {
          html += '</tr></thead>';
        } else if (i === (footRowStartIndex - 1)) {
          html += '</tr></tbody>';
        } else if (i === footRowEndIndex) {
          html += '</tfoot></tbody>';
        } else {
          html += '</tr>';
        }
      }
      self.table.html(html);
      self.table.tablesorter({ sortInitialOrder: 'desc' });
    });
  };

  self.initialize(options);

  return self;
});
