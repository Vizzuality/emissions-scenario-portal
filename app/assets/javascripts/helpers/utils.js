(function(App) {

  'use strict';

  App.Helper = App.Helper || {};

  App.Helper.Utils = {
    getURLParams: function () {
      var params = {}, hash;
      if (window.location.href.indexOf('?') == -1) {
        return false;
      }
      var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
      var route = 'http://' + window.location.host + window.location.pathname;
      if ( hashes[0] === route || hashes[0] === "") {
        return false;
      }
      for ( var i = 0; i < hashes.length; i++ ) {
        hash = hashes[i].split('=');
        params[hash[0]] = hash[1];
      }
      return params;
    }
  };

})(this.App);
