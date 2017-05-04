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
      self.svg.replaceWith('<svg />');
      self.svg = self.el.find('svg');
    }
    // TODO: Spinner el
    self.spinner = self.el.find('.spinner-container');
    self.defaultProperties = self.el.data('properties');
    self.form = self.el.find('.reports_kit_report_form');

    self.initializeElements();
    self.initializeEvents();
    self.render();
  };

  self.initializeElements = function() {
    self.form.find('.select2').each(function(index, el) {
      el = $(el);
      path = el.data('path');
      el.select2({
        minimumResultsForSearch: 10,
        ajax: {
          url: path,
          dataType: 'json',
          delay: 250,
          data: function(params) {
            var data = {
              q: params.term,
              page: params.page
            }
            var staticParams = $('[data-role=static_params]').val()
            if (staticParams) {
              staticParams = JSON.parse(staticParams)
              data = $.extend(data, staticParams)
            }
            return data;
          },
          processResults: function(data, params) {
            params.page = params.page || 1;
            return { results: data.data }
          },
          cache: true
        }
      });
    });
  };

  self.initializeEvents = function() {
    self.form.find('select,input').on('change', function() {
      self.render();
    })
    self.form.on('submit', function() {
      self.render();
      return false;
    })
  };

  self.xTickFormat = function(value) {
    if (self.isInt(value)) {
      return d3.time.format('%b %e, \'%y')(new Date(value));
    } else {
      return value;
    }
  };

  self.isInt = function(value) {
    return value === parseInt(value, 10);
  };

  self.properties = function() {
    var filterKeysValues = {};
    var checkboxKeysEnableds = {};
    self.form.find('select,:text').each(function(index, el) {
      var filter = $(el);
      var key = filter.attr('name');
      filterKeysValues[key] = filter.val();
    });
    self.form.find(':checkbox').each(function(index, el) {
      var filter = $(el);
      var key = filter.attr('name');
      checkboxKeysEnableds[key] = filter.prop('checked');
    });
    self.defaultProperties.measure.filters = $.map(self.defaultProperties.measure.filters, function(filter) {
      var value = filterKeysValues[filter.key];
      if (value !== undefined) {
        filter.criteria.value = value;
      }
      var enabled = checkboxKeysEnableds[filter.key];
      if (enabled !== undefined) {
        filter.criteria.operator = enabled ? 'true' : 'false';
      }
      return filter;
    });
    return self.defaultProperties;
  };

  self.render = function() {
    self.svg.fadeTo(1000, 0.3);
    self.spinner.fadeIn(1000);
    self.spinner.removeClass('hidden');
    let path = self.el.data('path') + 'reports_kit/reports?'
    path += $.param({ 'properties': self.properties() });
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
  };

  self.initialize(options);

  return self;
});
