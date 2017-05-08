ReportsKit.Chart = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.report = options.report;
    self.el = self.report.el;

    self.canvas = $('<canvas height="300" />').appendTo(self.el);
  };

  self.render = function() {
    let path = self.el.data('path') + 'reports_kit/reports?'
    path += $.param({ 'properties': self.report.properties() });
    $.getJSON(path, function(response) {
      var data = response.data;
      var chart_data = data.chart_data

      var args = {
        type: data.type,
        data: chart_data,
        options: chart_data.options
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
