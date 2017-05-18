(function(App) {

  'use strict';

  App.Controller = App.Controller || {};

  App.Controller.Scenarios = App.Controller.Page.extend({

    index: function () {
      new App.View.TableOrderFilter({
        el: '.js-table-order-filters'
      });
    },

    show: function () { },

    edit: function () { }

  });

})(this.App);
