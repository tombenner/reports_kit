ReportsKit.Chart = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.noResultsEl = $('<div>No data was found</div>').appendTo(self.report.visualizationEl).hide();
    self.loadingIndicatorEl = $('<div class="loading_indicator"></div>').appendTo(self.report.visualizationEl).hide();
    self.canvas = $('<canvas />').appendTo(self.report.visualizationEl);
  };

  self.render = function() {
    var path = self.el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + encodeURIComponent(JSON.stringify(self.report.properties()));
    self.loadingIndicatorEl.fadeIn(5000);
    $.getJSON(path, function(response) {
      var data = response.data;
      var chartData = data.chart_data;
      var options = chartData.options;
      options = self.addAdditionalOptions(options, chartData.standard_options)

      var args = {
        type: data.type,
        data: chartData,
        options: options
      };
      self.loadingIndicatorEl.stop(true, true).hide();

      if (self.chart) {
        self.chart.data.datasets = chartData.datasets;
        self.chart.data.labels = chartData.labels;
        self.chart.update();
      } else {
        self.chart = new Chart(self.canvas, args);
      }
      self.noResultsEl.toggle(self.chart.data.labels.length === 0);
    });
  };

  self.addAdditionalOptions = function(options, standardOptions) {
    var additionalOptions = {};
    var maxItems = standardOptions && standardOptions.legend && standardOptions.legend.max_items;
    if (maxItems) {
      options.legend = options.legend || {};
      options.legend.labels = options.legend.labels || {};
      options.legend.labels.filter = options.legend.labels.filter || function(item) { return item.datasetIndex < maxItems; };
    }
    return options;
  };

  self.initialize(options);

  return self;
});
