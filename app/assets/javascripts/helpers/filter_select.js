(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.FilterSelect = Backbone.View.extend({

    events: {
      'select2:select' : '_onSelect'
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

    _cache: function () {
      this.key = this.$el.data('filter-key');
    },

    _onSelect : function (e) {
      this.selectedValues = [$(e.currentTarget).find('select').val()];
      this._runCallback();
    },

    _runCallback: function() {
      if (typeof this.options.callback == "function") {
        this.options.callback();
      }
    },

    _setSelectFilters: function() {
      var activeFilter = App.Helper.Utils.getURLParams();
      if (typeof(activeFilter[this.key]) !== "undefined") {
        this.$el.find('select').val(activeFilter[this.key]);
      }
    }
  });

})(this.App);
