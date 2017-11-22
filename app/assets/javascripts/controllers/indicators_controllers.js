(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Data = {};

  var getCategories = function() {
    var grouped = _.groupBy(App.Data.categories, function(category) {
      return category.parent_id;
    });

    Object.keys(grouped).forEach(function(parent_id) {
      grouped[parent_id] = grouped[parent_id].map(function(category) {
        return String(category.id);
      });
    });

    return grouped;
  };

  var initializeSelectBehaviour = function() {
    var $categorySelect = $('select[name="indicator[category_id]"]');
    var $subcategorySelect = $('select[name="indicator[subcategory_id]"]');

    $categorySelect.change(function() {
      var subcategory_ids = getCategories()[this.value];
        $subcategorySelect.find('option').each(function() {
        if (_.isEmpty(subcategory_ids) && this.value !== '') {
          $(this).attr('disabled', 'disabled');
        } else if (_.includes(subcategory_ids, this.value) || this.value === '') {
          $(this).removeAttr('disabled');
        } else {
          $(this).attr('disabled', 'disabled');
        }
      });

      if (!_.includes(subcategory_ids, $subcategorySelect.val())) {
        $subcategorySelect.val('');
      }

      $subcategorySelect.select2({
        minimumResultsForSearch: Infinity
      });
    });

    $categorySelect.trigger('change');
  };

  App.Controller.Indicators = App.Controller.Page.extend({

    index: function () {
      new App.View.Filters({});
      new App.View.Form();
      _.each($('.js-upload-card'), function(element) {
        new App.Helper.InputFileUploader({
          el: element
        });
      }.bind(this));
    },

    show: function () {
      new App.View.Filters({});
      new App.View.Form();
      new App.View.Table();
    },

    edit: function () {
      new App.View.Form();
      initializeSelectBehaviour();
    },

    'new': function () {
      new App.View.Form();
      initializeSelectBehaviour();
    },

    fork: function() {
      new App.View.Form();
    }

  });

})(this.App);
