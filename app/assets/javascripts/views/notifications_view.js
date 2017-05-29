(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Notifications = Backbone.View.extend({

    el: '.c-notifications-list',

    events: {
      'click .js-notification' : '_onClickHideNotification'
    },

    _onClickHideNotification: function (e) {
      var target = $(e.currentTarget);
      var hideNotification = target.clone()
        .removeClass('-show-animation')
        .addClass('-hide-animation');

      target.before(hideNotification).remove();
    }

  });

})(this.App);
