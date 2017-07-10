ReportsKit.Chart = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.canvas = $('<canvas />').appendTo(self.report.visualizationEl);
  };

  self.render = function() {
    var path = self.el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + JSON.stringify(self.report.properties());
    $.getJSON(path, function(response) {
      var data = response.data;
      var chart_data = data.chart_data;
      var options = chart_data.options;

      var args = {
        type: data.type,
        data: chart_data,
        options: options
      };

      if (self.chart) {
        self.chart.data.datasets = chart_data.datasets;
        self.chart.data.labels = chart_data.labels;
        self.chart.update();
      } else {
        self.chart = new Chart(self.canvas, args);
      }
    });
  };

  self.initialize(options);

  return self;
});
