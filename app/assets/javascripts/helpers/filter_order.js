(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.FilterOrder = Backbone.View.extend({

    events: {
      'click .js-order-filter[data-column-key]' : '_onClickChangeOrder'
    },

    options: {
      selectedClass: '-selected'
    },

    initialize: function(settings) {
      if (!this.el) {
        return;
      }
      var opts = settings && settings.options ? settings.options : {};
      this.options = _.extend({}, this.options, opts);

      this.selectedValues = [];

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

      this._setSelectedValues();
      this._runCallback();
    },

    _getDefaultColumnsDirection: function () {
      var output = {};
      _.each(this.buttons, function(button) {
        output[$(button).data('column-key')] = 'asc';
      }.bind(this));

      return output;
    },

    _runCallback: function() {
      if (typeof this.options.callback == "function") {
        this.options.callback();
      }
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
      var activeFilter = this._getFiltersFromUrl();
      if (typeof(activeFilter.order_type) !== "undefined") {
        this.currentOrderType = activeFilter.order_type;
        this.columnsDirection[activeFilter.order_type] = activeFilter.order_direction === 'desc' ? 'desc' : 'asc';
        this._setSelectedValues();
      }

      $('.js-order-filter[data-column-key="' + this.currentOrderType + '"]').addClass(this.options.selectedClass);
    },

    _setSelectedValues: function () {
      this.selectedValues = 'order_type=' + this.currentOrderType +
        '&order_direction=' + this.columnsDirection[this.currentOrderType];
    }
  });

})(this.App);
