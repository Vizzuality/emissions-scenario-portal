// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require URIjs
//= require turbolinks
//= require underscore/underscore
//= require backbone/backbone
//= require select2
//= require tether
//= require drop
//= require tether-tooltip
//= require_self

//= require_tree ./helpers/
//= require_tree ./views/
//= require_tree ./controllers/

//= require router
//= require dispatcher

(function() {

  'use strict';

  this.App = {
    Events: _.extend(Backbone.Events),
    View: {},
    Controller: {}
  };

}).call(this);
