ReportsKit.Report = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.el = options.el;

    self.defaultProperties = self.el.data('properties');
    self.form = self.el.find('.reports_kit_report_form');

    self.initializeElements();
    self.initializeEvents();

    self.chart = new ReportsKit.Chart({ report: self });
    self.render();
  };

  self.initializeElements = function() {
    self.form.find('.date_range_picker').daterangepicker({
      locale: {
        format: 'MMM D, YYYY'
      },
      startDate: moment().subtract(3, 'months'),
      endDate: moment(),
      ranges: {
        'Today': [moment(), moment()],
        'Last 7 Days': [moment().subtract(7, 'days'), moment()],
        'Last 30 Days': [moment().subtract(30, 'days'), moment()],
        'Last 2 Months': [moment().subtract(2, 'months'), moment()],
        'Last 3 Months': [moment().subtract(3, 'months'), moment()],
        'Last 4 Months': [moment().subtract(4, 'months'), moment()],
        'Last 6 Months': [moment().subtract(6, 'months'), moment()],
        'Last 12 Months': [moment().subtract(12, 'months'), moment()]
      }
    });
    self.form.find('.select2').each(function(index, el) {
      el = $(el);
      var path = el.data('path');
      var elParams = el.data('params');
      el.select2({
        theme: 'bootstrap',
        minimumResultsForSearch: 10,
        ajax: {
          url: path,
          dataType: 'json',
          delay: 250,
          data: function(params) {
            var data = {
              q: params.term,
              page: params.page
            };
            data = $.extend(data, elParams);
            var staticParams = $('[data-role=static_params]').val();
            if (staticParams) {
              staticParams = JSON.parse(staticParams);
              data = $.extend(data, staticParams);
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
    var properties = $.extend({}, self.defaultProperties);
    properties.measure.filters = $.map(properties.measure.filters, function(filter) {
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
    return properties;
  };

  self.render = function() {
    self.chart.render();
  };

  self.initialize(options);

  return self;
});
