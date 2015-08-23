{Router} = require 'express'
path = require 'path'
_ = require 'lodash'

###
  Class: Abstract plugin, managed by {PluginManager}.
###
class Plugin
  # Public: {String}
  name: null
  # Public: {String}
  path: null
  # Public: {Object}
  config: {}
  # Public: {Array} or {String}
  dependencies: []

  @create: ({PluginClass, name, path, config}) ->
    instance = new PluginClass()

    _.extend instance,
      name: name
      path: path
      config: config

    instance.injector = new InjectorHelpers instance

    return instance

  ###
    Public: Constructor.

    * `injector` {Injector}

  ###
  constructor: (@injector) ->

  ###
    Public: Resolve path based on plugin directory.
  ###
  resolve: ->
    return root.resolve 'plugins', @name, arguments...

  ###
    Public: Get translator of plugin.

    * `language` {String} or {ClientRequest}

    Return {Function} `(name, params) -> String`.
  ###
  getTranslator: (language) ->

###
  Class: Private injector of {Plugin}.
###
class InjectorHelpers
  constructor: (@plugin) ->

  router: (path) ->
    router = new Router()
    root.express.use path, router

    root.routers.push
      path: path
      router: router
      plugin: @plugin

    return router

  ###
    Public: Register a hook, proxy of {HookRegistry::register}.
  ###
  hook: (path, options) ->
    return root.hooks.register path, _.extend options,
      plugin: @plugin

  ###
    Public: Register a view, proxy of {ViewRegistry::register}.
  ###
  view: (view, options) ->
    return root.views.register view, _.extend options,
      plugin: @plugin

  ###
    Public: Register a widget, proxy of {WidgetRegistry::register}.
  ###
  widget: (view, options) ->
    return root.widgets.register view, _.extend options,
      plugin: @plugin

  ###
    Public: Register a component, proxy of {ComponentRegistry::register}.
  ###
  component: (name, options) ->
    return root.components.register name, _.extend options,
      plugin: @plugin

  ###
    Public: Register a coupon type, proxy of {CouponTypeRegistry::register}.
  ###
  couponType: (name, options) ->
    return root.couponTypes.register name, _.extend options,
      plugin: @plugin

  ###
    Public: Register a payment provider, proxy of {PaymentProviderRegistry::register}.
  ###
  paymentProvider: (name, options) ->
    return root.paymentProviders.register name, _.extend options,
      plugin: @plugin

###
  Manager: Plugin manager,
  You can access a global instance via `root.plugins`.
###
module.exports = class PluginManager
  constructor: (@config) ->
    @plugins = {}

    for name, config of @config
      if config.enable
        @add name, path.join(__dirname, '../plugins', name), config

  ###
    Public: Add a plugin.

    * `name` {String}
    * `path` {String}
    * `config` {Object} `plugins.$name` of config object.

    Return {Plugin}.
  ###
  add: (name, path, config) ->
    if @plugins[name]
      throw new Error "Plugin `#{name}` already exists"

    @plugins[name] = plugin = Plugin.create
      name: name
      path: path
      config: config
      PluginClass: require path

    plugin.activate()

    return plugin

  ###
    Public: Get all plugins.

    Return {Array} of {Plugin}.
  ###
  all: ->
    return _.values @plugins

  ###
    Public: Get specified plugin.

    * `name` {String}

    Return {Plugin}.
  ###
  byName: (name) ->
    return @plugins[name]

  getRegisteredExtends: (plugin) ->
    filter = (registeredExtends) ->
      return _.filter registeredExtends, ({plugin: {name}}) ->
        return plugin.name == name

    return {
      routers: filter root.routers
      hooks: filter root.hooks.getHooksAsArray()
      views: filter root.views.getExpansionsAsArray()
      widgets: filter root.widgets.getWidgetsAsArray()
      components: filter root.components.all()
      couponTypes: filter root.couponTypes.all()
      paymentProviders: filter root.paymentProviders.all()
    }

PluginManager.Plugin = Plugin