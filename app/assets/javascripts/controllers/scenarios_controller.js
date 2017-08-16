(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Scenarios = App.Controller.Page.extend({

    index: function () {
      _.each($('.js-upload-card'), function(element) {
        new App.Helper.InputFileUploader({
          el: element
        });
      }.bind(this));

      new App.View.Filters({});
    },

    show: function () {
      new App.View.Filters({});
      new App.View.Form();
    },

    edit: function () {
      new App.View.Form();
    }

  });

})(this.App);
