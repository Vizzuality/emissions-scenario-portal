(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.TableOrderFilter = Backbone.View.extend({

    events: {
      'click .js-order-filter' : '_onClickChangeOrder'
    },

    options: {
      selectedClass: '-selected'
    },

    initialize: function() {
      this._cache();
      this._setSelectFilters();
    },

    _cache: function() {
      this.buttons = $('.js-order-filter');
      this.columnsDirection = this._getDefaultColumnsDirection();
      this.currentOrderType = 'name';
    },

    _onClickChangeOrder : function (e) {
      var target = $(e.currentTarget);
      var columnKey = target.data('column-key');

      this.columnsDirection[columnKey] = this.columnsDirection[columnKey] === 'asc' ? 'desc' : 'asc';
      this.currentOrderType = columnKey;

      this.buttons.removeClass(this.options.selectedClass);
      target.addClass(this.options.selectedClass);

      this._setHash();
    },

    _setHash: function () {
      var url = '?' + this._getFilterValue();
      Turbolinks.visit(url, {});
    },

    _getDefaultColumnsDirection: function () {
      var output = {};
      _.each(this.buttons, function(button) {
        output[$(button).data('column-key')] = 'asc';
      }.bind(this));

      return output;
    },

    _getFilterValue: function() {
      return 'order_type=' + this.currentOrderType + '&order_direction=' + this.columnsDirection[this.currentOrderType];
    },

    _getFiltersFromUrl: function() {
      var vars = {}, hash;
      var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
      var route = 'http://' + window.location.host + window.location.pathname;
      if ( hashes[0] === route || hashes[0] === "") {
        return false;
      }
      for ( var i = 0; i < hashes.length; i++ ) {
        hash = hashes[i].split('=');
        vars[hash[0]] = hash[1];
      }
      return vars;
    },

    _setSelectFilters: function() {
      var activeFilter = this._getFiltersFromUrl();
      if (typeof(activeFilter.order_type) !== "undefined") {
        this.currentOrderType = activeFilter.order_type;
        this.columnsDirection[activeFilter.order_type] = activeFilter.order_direction === 'desc' ? 'desc' : 'asc';

        $('.js-order-filter[data-column-key="' + activeFilter.order_type + '"]').addClass(this.options.selectedClass);
      }
    },

  });

})(this.App);