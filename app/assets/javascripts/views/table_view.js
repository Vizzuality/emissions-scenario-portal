(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Table = Backbone.View.extend({

    el: '.js-table',

    events: {
    },

    initialize: function() {
      this._cache();
      this._formatData();
      this._loadTable();
      this._setEvents();
    },

    _cache: function() {
      this.$parent = this.$el.parent();
      this.columns = [];
      this.rows = [];
    },

    _setEvents: function () {
      $(window).on('resize', this._adjustTableMargins);
    },

    _loadTable: function () {
      this._setParentHeight();
      var gridOptions = {
        columnDefs: this.columns,
        rowData: this.rows,
        enableSorting: true,
        unSortIcon: true,
        headerHeight: 33,
        rowHeight: 60,
        colWidth: 150,
        icons: {
          sortUnSort: '<svg class="icon"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#icon-short"></use></svg>',
          sortAscending: '<svg class="icon"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#icon-short"></use></svg>',
          sortDescending: '<svg class="icon"><use xmlns:xlink="http://www.w3.org/1999/xlink" xlink:href="#icon-short"></use></svg>'
        }
      };
      new agGrid.Grid(this.$el[0], gridOptions);
      this._adjustTableMargins();
    },

    _setParentHeight: function () {
      this.$parent.css('height', $(window).height() - $('body').height());
    },

    _adjustTableMargins: function () {
      var margin = ($('body').width() - $('.small-12').width()) / 2;
      $('.ag-header').css('padding-left', margin);
      $('.ag-body').css('left', margin);
    },
    
    _formatData: function () {
      switch (this.$el.data('type')) {
        case 'time_series':
          this._formatTimeSeries();
          break;
      }
    },

    _formatTimeSeries: function () {
      var years = this.$el.data('indicators');
      var rows = this.$el.data('rows');

      this.columns.push({headerName: "Country", field: "country", cellClass: 'f-ff1-m-bold', pinned: true});
      _.each(years, function(year) {
        this.columns.push({headerName: year.toString(), field: year.toString()});
      }.bind(this));

      _.each(rows, function(row) {
        var yearValues = {};
        _.each(row.values, function(yearValue, i) {
          yearValues[years[i].toString()] = yearValue;
        });

        this.rows.push(_.extend({country: row.location_name}, yearValues));
      }.bind(this));
    }
    
  });

})(this.App);
