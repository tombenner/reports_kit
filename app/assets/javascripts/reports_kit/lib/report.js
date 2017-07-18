ReportsKit.Report = (function(options) {
  var self = this;

  self.initialize = function(options) {
    self.options = options;
    self.el = options.el;
    self.visualizationEl = self.el.find('.reports_kit_visualization');

    self.defaultProperties = self.el.data('properties');
    self.form = self.el.find('.reports_kit_report_form');

    self.initializeElements();
    self.initializeEvents();

    if (self.defaultProperties.format == 'table') {
      self.visualization = new ReportsKit.Table({ report: self });
    } else {
      self.visualization = new ReportsKit.Chart({ report: self });
    }
    self.render();
  };

  self.initializeElements = function() {
    self.exportButtons = self.el.find('[data-role=reports_kit_export_button]');
    self.form.find('.date_range_picker').daterangepicker({
      locale: {
        format: 'MMM D, YYYY'
      },
      ranges: {
        'Today': [moment(), moment()],
        'Last 7 Days': [moment().subtract(7, 'days'), moment()],
        'Last 30 Days': [moment().subtract(30, 'days'), moment()],
        'Last 2 Months': [moment().subtract(2, 'months'), moment()],
        'Last 3 Months': [moment().subtract(3, 'months'), moment()],
        'Last 4 Months': [moment().subtract(4, 'months'), moment()],
        'Last 6 Months': [moment().subtract(6, 'months'), moment()],
        'Last 12 Months': [moment().subtract(12, 'months'), moment()],
        'Year To Date': [moment().startOf('year'), moment()]
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
    self.exportButtons.on('click', self.onClickExportButton);
  };

  self.properties = function() {
    var filterKeysValues = {};
    self.form.find('select,:text').each(function(index, el) {
      var filter = $(el);
      var key = filter.attr('name');
      filterKeysValues[key] = filter.val();
    });
    self.form.find(':checkbox').each(function(index, el) {
      var filter = $(el);
      var key = filter.attr('name');
      filterKeysValues[key] = filter.prop('checked');
    });
    var properties = $.extend({}, self.defaultProperties);

    properties.ui_filters = {};
    Object.keys(filterKeysValues).forEach(function(key, index) {
      var value = filterKeysValues[key];
      properties.ui_filters[key] = value;
    });

    return properties;
  };

  self.onClickExportButton = function(event) {
    var el = $(event.target);
    var path = el.data('path');
    var separator = path.indexOf('?') === -1 ? '?' : '&';
    path += separator + 'properties=' + encodeURIComponent(JSON.stringify(self.properties()));
    window.open(path, '_blank');
    return false;
  };

  self.render = function() {
    self.visualization.render();
  };

  self.initialize(options);

  return self;
});
