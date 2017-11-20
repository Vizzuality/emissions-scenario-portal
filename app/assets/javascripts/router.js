(function(App) {

  'use strict';

  var routes = {
    '': 'Models#index',
    'models': 'Models#index',
    'models/:id': 'Models#show',
    'models/:id/edit': 'Models#edit',
    'models/:modelId/scenarios': 'Scenarios#index',
    'models/:modelId/scenarios/upload_meta_data': 'Scenarios#index',
    'models/:modelId/scenarios/:id': 'Scenarios#show',
    'models/:modelId/scenarios/:id/edit': 'Scenarios#edit',
    'models/:modelId/indicators': 'Indicators#index',
    'models/:modelId/indicators/:id/edit': 'Indicators#edit',
    'models/:modelId/indicators/:id/fork': 'Indicators#fork',
    'models/:modelId/indicators/:id': 'Indicators#show',
    'indicators': 'Indicators#index',
    'indicators/:id/edit': 'Indicators#edit',
    'indicators/:id': 'Indicators#show',
    'teams': 'Teams#index',
    'teams/:id/edit': 'Teams#edit',
    'teams/:id': 'Teams#edit',
    'locations': 'Teams#index',
    'locations/:id/edit': 'Teams#edit',
    '*notFound': 'Error#index'
  };

  var optionalTrailingSlash = function(routes) {
    return Object.keys(routes).reduce(function(result, current) {
      result[current + '(/)'] = routes[current];
      return result;
    }, {});
  };

  App.Router = Backbone.Router.extend({

    /**
     * Inspired by Rails, we have a routes file that specifies these routes
     * and any additional route parameters.
     * @type {Object}
     */
    routes: optionalTrailingSlash(routes),

    initialize: function() {
      // We are going to save params in model
      this.params = new (Backbone.Model.extend());
      // Listening events
      this.params.on('change', _.bind(this.updateUrl, this));
    },

    /**
     * Get URL params
     * @return {Object}
     */
    getParams: function(routeParams) {
      return this._unserializeParams(routeParams);
    },

    /**
     * Change URL with current params
     */
    updateUrl: function() {
      var url = location.pathname.slice(1) + this._serializeParams();
      this.navigate(url, { trigger: false });
    },

    /**
     * Transform URL string params to object
     * @param  {String} routeParams
     * @return {Object}
     * @example https://medialize.github.io/URI.js/docs.html
     */
    _unserializeParams: function(routeParams) {
      var params = {};
      if (typeof routeParams === 'string' && routeParams.length) {
        var uri = new URI('?' + routeParams);
        params = uri.search(true);
      }
      return params;
    },

    /**
     * Transform object params to URL string
     * @return {String}
     * @example https://medialize.github.io/URI.js/docs.html
     */
    _serializeParams: function() {
      var uri = new URI();
      uri.search(this.params.attributes);
      return uri.search();
    }

  });

})(this.App);
