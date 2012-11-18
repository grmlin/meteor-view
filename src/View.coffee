do ->
  ERROR_MIXIN_NO_OBJECT = "Meteor.View: viewMixin has to be an object!"
  ERROR_NO_CONSTRUCTOR = "Meteor.View: has to be used as a constructor function with the \"new\" keyword"
  ERROR_TEMPLATE_UNAVAILABLE = "Meteor.View: There is no template named "
  ERROR_NO_GETTERS = "Meteor.View: You're using elements maps in an unsupported browser! Take care the browser supports setting getters by calling \"__defineGetter__\""
  ERROR_METHOD_MISSING = "Meteor.View: a method you used inside a map does not exist: "

  class View
    initialize: null
    
    elements: null
    events: null
    helpers: null
    callbacks: null

    _templateWrapper: null
    _template: null

    constructor: (@name) ->
      ctx = @

      unless @ instanceof View
        throw new TypeError ERROR_NO_CONSTRUCTOR
      unless Template[@name]
        throw new Error ERROR_TEMPLATE_UNAVAILABLE + @name

      # ## First of all, store the template
      @_templateWrapper = Template[@name]

      # ## Create the events
      eventsMap = {}
      unless @events is null
        for own event, handler of @events
          eventsMap[event] = @_getMethod(handler)

      @_templateWrapper.events(eventsMap)

      # ## Add the helper callbacks
      helpersMap = {}
      unless @helpers is null
        for own helper, handler of @helpers
          helpersMap[helper] = @_getMethod(handler)

      @_templateWrapper.helpers helpersMap

      # ## Bind the created and destroyed callbacks so we can update the template instance
      @_templateWrapper.created = ->
        ctx._template = @

      @_templateWrapper.destroyed = ->
        ctx._template = null

      # ## Wire up the callbacks
      unless @callbacks is null
        for own name, handler of @callbacks
          @_bindCallback(name, handler)

      # ## define getters for all the elements in the elements map

      unless @elements is null
        for own selector, member of @elements
          do (selector) =>
            throw new Error ERROR_NO_GETTERS if typeof @.__defineGetter__ isnt "function"
            @.__defineGetter__(member, ->
              if @_template isnt null
                return @_template.findAll(selector)
              else
                return []
            )
          
      @initialize.apply(@, _.toArray(arguments).slice(1)) if @initialize isnt null

    _getMethod: (name) ->
      throw new TypeError ERROR_METHOD_MISSING + name if typeof @[name] isnt "function"
      
      ctx = @
      m = -> 
        ctx[name].apply ctx, _.toArray(arguments)

    _bindCallback: (name, handler) ->
      ctx = @
      method = @_getMethod(handler)
      oldMethod = @_templateWrapper[name]
      
      @_templateWrapper[name] = ->
        args = _.toArray(arguments)
        method.apply(ctx, ([this]).concat(args))
        oldMethod?.apply(this, args)

  Meteor.View =
    create: (viewMixin) ->
      throw new TypeError ERROR_MIXIN_NO_OBJECT unless typeof viewMixin is "object"

      class MeteorView extends View
        constructor: (name) ->
          super

      _.extend(MeteorView.prototype, viewMixin)

      return MeteorView
      
  
  
