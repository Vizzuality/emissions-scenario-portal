(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.FormItem = Backbone.View.extend({

    el: '.c-form-item',

    events: {
      'focus .js-form-input': '_onFocusInput',
      'focusout .js-form-input': '_onFocusOutInput',
      'select2:open .js-form-input': '_onFocusInput',
      'select2:close .js-form-input': '_onFocusOutInput',
    },

    options: {
      highlightedClass: "-highlighted"
    },

    _onFocusInput: function (e) {
      var formItem = $(e.currentTarget).closest('.c-form-item');
      formItem.addClass(this.options.highlightedClass);
    },

    _onFocusOutInput: function (e) {
      this._checkValue($(e.currentTarget));
    },

    _checkValue: function (element) {
      if (element.val() === '' || element.val() === null) {
        element.closest('.c-form-item').removeClass(this.options.highlightedClass);
      }
    }

  });

})(this.App);
