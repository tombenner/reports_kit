ReportsKit.Report = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.el = options.el;
    self.config = {
      'max_items_in_legend': 15,
      'render_duration': 300,
      'transition_duration': 250
    };

    // TODO: ?
    self.should_redraw = true;

    self.svg = $('<svg />').appendTo(self.el);
    if (self.should_redraw) {
      // This isn't sufficient, as the old chart is still bound to the <svg> and will show up if you resize the window
      // d3.select(@svg[0]).selectAll('*').remove()
      self.svg.replaceWith('<svg />');
      self.svg = self.el.find('svg');
    }
    // TODO: Spinner el
    self.spinner = self.el.find('.spinner-container');
    self.properties = self.el.data('properties');
    self.render();
  }

  self.xTickFormat = function(value) {
    if (self.isInt(value)) {
      return d3.time.format('%b %e, \'%y')(new Date(value));
    } else {
      return value;
    }
  }

  self.isInt = function(value) {
    return value === parseInt(value, 10);
  }

  self.render = function() {
    self.svg.fadeTo(1000, 0.3);
    self.spinner.fadeIn(1000);
    self.spinner.removeClass('hidden');
    let path = self.el.data('path') + 'reports_kit/reports?'
    path += $.param({ 'properties': self.properties });
    return d3.json(path, (error, response) => {
      self.spinner.addClass('hidden');
      self.svg.stop().fadeTo(500, 1);
      if (error) {
        alert('Sorry, an error occurred!');
        return;
      }
      var data = response.data;
      var chart_data = data.chart_data

      let chart_wrapper = self.svg.find('.nvd3.nv-wrap');
      if ((chart_data.length === 0) || (chart_data[0].values.length === 0)) {
        chart_wrapper.css('visibility', 'hidden');
      } else {
        chart_wrapper.css('visibility', 'visible');
      }

      // We have the default here to support older bodhi endpoints that don't send display_format
      let display_format = data.display_format;
      let showLegend = chart_data.length < self.config.max_items_in_legend;

      return nv.addGraph(() => {
        let chart;
        switch (display_format) {
          case 'bar':
            chart = nv.models.multiBarChart()
              .delay(self.config.render_duration)
              .transitionDuration(self.config.transition_duration)
              .showLegend(showLegend)
              .reduceXTicks(true)
              .rotateLabels(0)
              .showControls(true)
              .groupSpacing(0.1)
              .stacked(true)
              .noData('No data found');

            chart.xAxis
              .axisLabel(data.x_label)
              .axisLabelDistance(60)
              .tickFormat(self.xTickFormat);

            chart.yAxis
              .tickFormat(d3.format(',.f'))
              .axisLabel(data.y_label)
              .axisLabelDistance(40);
            break;

          case 'line':
            chart = nv.models.lineChart()
              .transitionDuration(self.config.transition_duration)
              .showLegend(showLegend)
              .noData('No data found');

            chart.xAxis
              .axisLabel(data.x_label)
              .axisLabelDistance(60)
              .tickFormat(self.xTickFormat);

            chart.yAxis
              .tickFormat(d3.format(',.f'))
              .axisLabel(data.y_label)
              .axisLabelDistance(40);
            d3.select(self.svg[0])
              .datum(chart_data)
              .call(chart);
            break;

          case 'area':
            chart = nv.models.stackedAreaChart()
              .useInteractiveGuideline(true)
              .transitionDuration(self.config.transition_duration)
              .showLegend(showLegend)
              .noData('No data found')
              .showControls(true);

            chart.xAxis
              .axisLabel(data.x_label)
              .axisLabelDistance(60)
              .tickFormat(self.xTickFormat);

            chart.yAxis
              .tickFormat(d3.format(',.f'))
              .axisLabel(data.y_label)
              .axisLabelDistance(40);
            d3.select(self.svg[0])
              .datum(chart_data)
              .call(chart);
            break;
        }


        d3.select(self.svg[0])
          .datum(chart_data)
          .call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
      });
    });
  }

  self.initialize(options);

  return self;
});
