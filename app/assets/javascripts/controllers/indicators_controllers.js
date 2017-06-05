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

    show: function () { },

    edit: function () {
      new App.View.Form();
    }

  });

})(this.App);
