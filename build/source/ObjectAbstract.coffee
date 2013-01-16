
rippl.ObjectAbstract = class ObjectAbstract
  #
  # Default options
  #
  options: {}

  # -----------------------------------

  _eventSeparator: new RegExp("\\s+")

  # -----------------------------------

  _validEventName: (event) ->
    return false if typeof event isnt 'string'
    return true

  # -----------------------------------

  _validCallback: (callback) ->
    return false if typeof callback isnt 'function'
    return true

  # -----------------------------------

  on: (events, callback) ->
    #
    # sets up an event handler for a specific event
    #
    return @ if not @_validCallback(callback)

    for event in events.split(@_eventSeparator)
      #
      # Create a container for event handlers
      #
      handlers = @_eventHandlers or (@_eventHandlers = {})
      #@_eventHandlers = {} if @_eventHandlers is null

      #
      # create a new stack for the callbacks if not defined yet
      #
      handlers[event] = [] if handlers[event] is undefined

      #
      # push the callback onto the stack
      #
      handlers[event].push(callback)

    return @

  # -----------------------------------

  once: (event, callback) ->
    padding = (args...) =>
      @off(event, callback)
      callback.apply(@, args)

    @on(event, padding)

  # -----------------------------------

  off: (event, callbackToRemove) ->
    return @ if not handlers = @_eventHandlers

    args = arguments.length

    if args is 0
      #
      # Drop all listeners
      #
      @_eventHandlers = {}

    else if args is 1
      #
      # Drop all listeners for specified event
      #
      return @ if handlers[event] is undefined

      delete handlers[event]

    else if event is null
      #
      # Drop callback from all handlers
      #
      for event of handlers
        stack = []

        for callback in handlers[event]
          stack.push(callback) if callback isnt callbackToRemove

        handlers[event] = stack

    else
      #
      # Drop only the specified callback from the stack
      #
      return @ if handlers[event] is undefined

      stack = []

      for callback in handlers[event]
        stack.push(callback) if callback isnt callbackToRemove

      handlers[event] = stack

    return @

  # -----------------------------------

  trigger: (event, args...) ->
    return @ if not handlers = @_eventHandlers

    #
    # triggers all listener callbacks of a given event, pass on the data from second argument
    #
    return @ if not @_validEventName(event)

    return @ if handlers[event] is undefined

    callback.apply(@, args) for callback in handlers[event]

    return @

  # -----------------------------------

  addDefaults: (defaults) ->
    #
    # Adds new defaults
    #
    if @options isnt undefined
      for option of @options
        defaults[option] = @options[option] if defaults[option] is undefined

    @options = defaults

  # -----------------------------------

  setOptions: (options) ->
    #
    # Set the @option property with new options or use defaults
    #
    if options isnt undefined

      defaults = @options
      @options = {}

      for option of defaults
        if options[option] isnt undefined
          @options[option] = options[option]
        else
          @options[option] = defaults[option]

      return true

    return false
