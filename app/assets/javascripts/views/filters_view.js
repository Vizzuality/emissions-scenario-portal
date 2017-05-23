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
        }
      }.bind(this));
    },

    _loadOrder: function(helperFilter) {
      this.filters.push(new App.Helper.FilterOrder(helperFilter));
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
      Turbolinks.visit(url, {})
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

    _getFiltersFromUrl: function() {
      var vars = {}, hash;
      var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
      var route = 'http://' + window.location.host + window.location.pathname;
      if ( hashes[0] === route || hashes[0] === "") {
        return false
      }
      for ( var i = 0; i < hashes.length; i++ ) {
        hash = hashes[i].split('=');
        vars[hash[0]] = hash[1];
      }
      return vars;
    },

    _setSelectFilters: function() {
      var activeFilters = this._getFiltersFromUrl();
      if (activeFilters === false) {
        return false
      }
      _.each(activeFilters, function(value, key) {
        var selectedValues = value.split(',');
        var filter = _.findWhere(this.filters, {key: key});
        if (typeof filter != 'undefined') {
          filter.selectedValues = selectedValues;
        }
      }.bind(this));
    }

  });

})(this.App);
