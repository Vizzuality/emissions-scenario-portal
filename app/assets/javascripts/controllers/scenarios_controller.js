(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Scenarios = App.Controller.Page.extend({

    index: function () {
      new App.View.TableOrderFilter({
        el: '.js-table-order-filters'
      });
      _.each($('.js-upload-card'), function(element) {
        new App.Helper.InputFileUploader({
          el: element
        });
      }.bind(this));
    },

    show: function () {
      new App.View.TableOrderFilter({
        el: '.js-table-order-filters'
      });
    },

    edit: function () {
      new App.View.Form();
    }

  });

})(this.App);
