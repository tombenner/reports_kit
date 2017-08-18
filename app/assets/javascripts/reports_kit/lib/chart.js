ReportsKit.Chart = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.defaultEmptyStateText = 'No data was found';
    self.emptyStateEl = $('<div>' + self.defaultEmptyStateText + '</div>').appendTo(self.report.visualizationEl).hide();
    self.loadingIndicatorEl = $('<div class="loading_indicator"></div>').appendTo(self.report.visualizationEl).hide();
    self.canvas = $('<canvas />').appendTo(self.report.visualizationEl);
  };

  self.render = function() {
    var path = self.el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + encodeURIComponent(JSON.stringify(self.report.properties()));
    self.loadingIndicatorEl.fadeIn(1000);
    if (self.canvas.is(':visible')) {
      self.canvas.fadeTo(300, 0.1);
    }
    $.getJSON(path, function(response) {
      var data = response.data;
      var chartData = data.chart_data;
      var isEmptyState = chartData.datasets.length === 0 ||
        (chartData.datasets.length === 1 && chartData.datasets[0].data.length === 0);
      var emptyStateText = (data.report_options && data.report_options.empty_state_text) || self.defaultEmptyStateText;
      var options = chartData.options;
      options = self.addAdditionalOptions(options, data.report_options);

      self.loadingIndicatorEl.stop(true, true).hide();
      self.emptyStateEl.html(emptyStateText).toggle(isEmptyState);
      if (isEmptyState) {
        self.canvas.hide();
        return;
      }
      self.canvas.show().fadeTo(300, 1);

      var args = {
        type: data.type,
        data: chartData,
        options: options
      };

      if (self.chart) {
        self.chart.data.datasets = chartData.datasets;
        self.chart.data.labels = chartData.labels;
        self.chart.update();
      } else {
        self.chart = new Chart(self.canvas, args);
      }
    });
  };

  self.addAdditionalOptions = function(options, reportOptions) {
    var additionalOptions = {};
    var maxItems = reportOptions && reportOptions.legend && reportOptions.legend.max_items;
    if (maxItems) {
      options.legend = options.legend || {};
      options.legend.labels = options.legend.labels || {};
      options.legend.labels.filter = options.legend.labels.filter || function(item) {
        var index = (typeof item.datasetIndex === 'undefined') ? item.index : item.datasetIndex;
        return index < maxItems;
      };
    }
    return options;
  };

  self.initialize(options);

  return self;
});
