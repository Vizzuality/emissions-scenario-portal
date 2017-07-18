(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

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
    },

    fork: function () {
      new App.View.Form();
    }

  });

})(this.App);
