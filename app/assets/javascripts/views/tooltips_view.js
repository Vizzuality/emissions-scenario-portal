(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Tooltips = Backbone.View.extend({

    initialize: function() {
      this._cache();
      this._loadTooltips();
    },

    _cache: function () {
      this.tooltips = $('.js-tooltip');
    },

    _loadTooltips: function () {
      _.each(this.tooltips, function(tooltip) {
        var text = $(tooltip).data('tooltip-text');
        if (text !== '') {
          new Tooltip({
            target: tooltip,
            content: text,
            classes: 'c-tooltip',
            position: 'bottom left'
          });
        }
      });
    },

    _checkValue: function (element) {
      if (element.val() === '' || element.val() === null) {
        element.closest('.c-form-item').removeClass(this.options.highlightedClass);
      }
    }

  });

})(this.App);
