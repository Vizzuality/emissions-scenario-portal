(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Indicators = App.Controller.Page.extend({

    index: function () {
      new App.View.Filters({});
    },

    show: function () { },

    edit: function () {
      new App.View.Form();
    }

  });

})(this.App);
