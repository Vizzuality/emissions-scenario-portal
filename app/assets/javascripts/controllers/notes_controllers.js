(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Notes = App.Controller.Page.extend({

    edit: function () {
      new App.View.Form();
    }

  });

})(this.App);
