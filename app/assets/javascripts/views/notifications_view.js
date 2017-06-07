(function(App) {

  'use strict';

  App.View = App.View || {};

  App.View.Notifications = Backbone.View.extend({

    el: '.c-notifications-list',

    events: {
      'click .js-notification' : '_onClickHideNotification',
      'click .js-upload-errors' : '_onClickUploadErrors'
    },

    _onClickHideNotification: function (e) {
      var target = $(e.currentTarget);
      var hideNotification = target.clone()
        .removeClass('-show-animation')
        .addClass('-hide-animation');

      target.before(hideNotification).remove();
    },

    _onClickUploadErrors: function (e) {
      var target = $(e.currentTarget);
      var a = document.body.appendChild(
        document.createElement('a')
      );
      a.download = 'upload_errors.csv';
      a.href='data:text/csv;charset=utf-8,' +
        escape(target.prev('.c-upload-errors-list').text());
      a.click();
    }
  });

})(this.App);
