(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Form = Backbone.View.extend({

    el: 'form',

    options: {
      selectTriggerClass: '.js-select',
      multipleSelectTriggerClass: '.js-multiple-select',
    },

    initialize: function() {
      this._cache();
      this._loadSelect();
      this._loadMultipleSelect();
    },

    _cache: function () {
      this.$selects = $(this.options.selectTriggerClass);
      this.$multipleSelects = $(this.options.multipleSelectTriggerClass);
    },

    _loadSelect: function () {
      this.$selects.select2({
        maximumSelectionLength: 1,
        tags: true
      });
    },

    _loadMultipleSelect: function () {
      this.$multipleSelects.select2({
        tags: true
      });
    },

  });

})(this.App);
