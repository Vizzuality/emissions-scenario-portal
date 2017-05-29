(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Locations = App.Controller.Page.extend({

    index: function () {
      new App.View.Filters({});
      new App.View.Form();
    },

    edit: function () {
      new App.View.FormVerticalNav();
      new App.View.Form();
    }

  });

})(this.App);
