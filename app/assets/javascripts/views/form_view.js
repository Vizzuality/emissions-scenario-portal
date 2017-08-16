(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Form = Backbone.View.extend({

    el: 'form',

    options: {
      selectTriggerClass: '.js-select',
      multisingleTriggerClass: '.js-multisingle-select',
      multipleSelectTriggerClass: '.js-multiple-select',
      datepickerTriggerClass: '.js-datepicker-input',
    },

    initialize: function() {
      this._cache();
      this._cleanSelect2();
      this._loadSelect();
      this._loadMultisingleSelect();
      this._loadMultipleSelect();
      this._loadDatepicker();
    },

    _cache: function () {
      this.$selects = $(this.options.selectTriggerClass);
      this.$multisingleSelects = $(this.options.multisingleTriggerClass);
      this.$multipleSelects = $(this.options.multipleSelectTriggerClass);
      this.$datepickerInput = $(this.options.datepickerTriggerClass + ':not([data-form-processed])');
    },

    _cleanSelect2: function () {
      $('.select2-container').remove();
      $('.select2-hidden-accessible').removeClass('select2-hidden-accessible');
    },

    _loadSelect: function () {
      this.$selects.select2({
        minimumResultsForSearch: Infinity
      });
    },

    _loadMultisingleSelect: function () {
      this.$multisingleSelects.select2({
        maximumSelectionLength: 1,
        tags: true
      });
    },

    _loadMultipleSelect: function () {
      _.each(this.$multipleSelects, function(element) {
        $(element).select2({
          tags: true,
          placeholder: $(element).data('placeholder')
        });
      });
    },

    _loadDatepicker: function () {
      this.$datepickerInput.datepicker({
        dateFormat: "yy-mm-dd"
      });
      this.$datepickerInput.attr('data-form-processed', true);
    }

  });

})(this.App);
