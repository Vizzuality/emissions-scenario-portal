(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.FilterMultiselect = Backbone.View.extend({

    events: {
      'select2:select' : '_onChange',
      'select2:unselect' : '_onChange'
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

    _onChange : function (e) {
      var values = $(e.currentTarget).find('select').val();
      this.selectedValues = values !== null ? values : [];
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
        var values = activeFilter[this.key].split(',');
        this.$el.find('select').val(values);
      }
    }
  });

})(this.App);
