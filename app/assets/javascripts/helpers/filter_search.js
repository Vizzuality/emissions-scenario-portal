(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.FilterSearch = Backbone.View.extend({

    events: {
      'keydown' : '_onKeydown',
      'keyup' : '_onKeyup'
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
      this._setClearButtonEvent();
    },

    _cache: function () {
      this.key = this.$el.data('filter-key');
      this.$clearButton = this.$el.siblings('.js-input-search-clear');
    },

    _onKeydown: function (e) {
      var value = $(e.currentTarget).val();

      if (e.keyCode === 13) {
        this.selectedValues = value !== '' ? [value] : [];
        this.options.callback();
      }

      this._checkClearButton(value);
    },

    _onKeyup: function (e) {
      var value = $(e.currentTarget).val();
      this._checkClearButton(value);
    },

    _setSelectFilters: function() {
      var activeFilter = App.Helper.Utils.getURLParams();
      if (typeof(activeFilter[this.key]) !== "undefined") {
        this.$el.val(activeFilter[this.key]);
      }
    },

    _setClearButtonEvent: function () {
      this.$clearButton.on('click', function () {
        this._cleanInput();
      }.bind(this))
    },

    _checkClearButton: function (value) {
      if (value !== '') {
        this.$clearButton.removeClass('-hidden');
      } else {
        this.$clearButton.addClass('-hidden');
      }
    },

    _cleanInput: function () {
      this.$el.val('');
    }
  });

})(this.App);
