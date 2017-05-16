(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Models = App.Controller.Page.extend({

    index: function () { },

    show: function () { },

    edit: function () {
      new App.View.FormVerticalNav();
      new App.View.Form();
    }

  });

})(this.App);
