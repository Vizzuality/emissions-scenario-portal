(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Filters = Backbone.View.extend({

    initialize: function(settings) {
      var opts = settings && settings.options ? settings.options : {};
      this.options = _.extend({}, this.options, opts);
      this.staticParams = typeof settings.staticParams !== "undefined" ? settings.staticParams : null;

      this._cache();
      this._loadFilters();
      this._setSelectFilters();
    },

    _cache: function() {
      this.$filters = $('.js-table-filter');
    },

    _loadFilters: function() {
      this.filters = [];
      _.each(this.$filters, function(item) {
        var filter = $(item);
        switch (filter.data("filter-type")) {
          case "order":
            this._loadOrder(this._getHelperFilterObject(filter));
            break;
          case "search":
            this._loadSearch(this._getHelperFilterObject(filter));
            break;
          case "select":
            this._loadSelect(this._getHelperFilterObject(filter));
            break;
          case "multiselect":
            this._loadMultiselect(this._getHelperFilterObject(filter));
            break;
        }
      }.bind(this));
    },

    _loadOrder: function(helperFilter) {
      this.filters.push(new App.Helper.FilterOrder(helperFilter));
    },

    _loadSearch: function(helperFilter) {
      this.filters.push(new App.Helper.FilterSearch(helperFilter));
    },

    _loadSelect: function(helperFilter) {
      this.filters.push(new App.Helper.FilterSelect(helperFilter));
    },

    _loadMultiselect: function(helperFilter) {
      this.filters.push(new App.Helper.FilterMultiselect(helperFilter));
    },

    _getHelperFilterObject: function(filter) {
      return {
        el: filter,
        options: {
          callback: this._filter.bind(this)
        }
      };
    },

    _filter: function() {
      this._setHash();
    },

    _setHash: function () {
      var url = '?' + this.getFilterValues();
      Turbolinks.visit(url, {});
    },

    getFilterValues: function() {
      var queryStr = '';
      _.each(this.filters, function (filter) {
        if (filter.selectedValues.length > 0 ) {
          if (queryStr !== '' ) {
            queryStr += '&';
          }

          if (typeof filter.key !== 'undefined') {
            queryStr += filter.key + '=';
            _.each(filter.selectedValues.sort(), function (value, index) {
              queryStr += value;
              if ( index < filter.selectedValues.length - 1 ) {
                queryStr += ',';
              }
            });
          } else {
            queryStr += filter.selectedValues;
          }
        }
      });
      if (this.staticParams !== null) {
        queryStr += this.staticParams;
      }

      return queryStr;
    },

    _setSelectFilters: function() {
      var activeFilters = App.Helper.Utils.getURLParams();
      if (activeFilters === false) {
        return false;
      }
      _.each(activeFilters, function(value, key) {
        var selectedValues = value.split(',');
        var filter = _.findWhere(this.filters, {key: key});
        if (typeof filter !== 'undefined') {
          filter.selectedValues = selectedValues;
        }
      }.bind(this));
    }

  });

})(this.App);
