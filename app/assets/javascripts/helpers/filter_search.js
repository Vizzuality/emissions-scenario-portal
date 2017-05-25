(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.FilterSearch = Backbone.View.extend({

    events: {
      'keydown' : '_onKeydown'
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

    _onKeydown : function (e) {
      if(e.keyCode === 13) {
        var value = $(e.currentTarget).val();

        this.selectedValues = value !== '' ? [$(e.currentTarget).val()] : [];
        this.options.callback();
      }
    },

    _setSelectFilters: function() {
      var activeFilter = App.Helper.Utils.getURLParams();
      if (typeof(activeFilter[this.key]) !== "undefined") {
        this.$el.val(activeFilter[this.key]);
      }
    }
  });

})(this.App);
