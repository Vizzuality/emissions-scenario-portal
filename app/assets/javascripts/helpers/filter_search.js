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
    },

    _cache: function () {
      this.key = this.$el.data('filter-key');
    },

    _onKeydown : function (e) {
      if(e.keyCode === 13) {
        this.selectedValues = [$(e.currentTarget).val()];
        this._runCallback();
      }
    },

    _runCallback: function() {
      if (typeof this.options.callback == "function") {
        this.options.callback();
      }
    }
  });

})(this.App);
