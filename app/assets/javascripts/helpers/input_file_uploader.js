(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.InputFileUploader = Backbone.View.extend({

    events: {
      'change': '_submitForm'
    },

    initialize: function() {
      if (!this.el) {
        return;
      }
      this._cache();
    },

    _cache: function () {
      this.form = this.$el.closest('form');
    },

    _submitForm: function () {
      this.form.submit();
    },

  });

})(this.App);
