(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Models = App.Controller.Page.extend({

    index: function () {
      _.each($('.js-upload-card'), function(element) {
        new App.Helper.InputFileUploader({
          el: element
        });
      }.bind(this));
    },

    show: function () {
      new App.View.FormVerticalNav();
      new App.View.Form();
    },

    edit: function () {
      new App.View.FormVerticalNav();
      new App.View.Form();
    }

  });

})(this.App);
