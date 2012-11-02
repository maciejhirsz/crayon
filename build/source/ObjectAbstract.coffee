
rippl.ObjectAbstract = class ObjectAbstract
  #
  # Default options
  #
  options: {}

  # -----------------------------------

  _eventHandlers: null

  # -----------------------------------

  _validEventName: (event) ->
    return false if typeof event isnt 'string'
    return true

  # -----------------------------------

  _validCallback: (callback) ->
    return false if typeof callback isnt 'function'
    return true

  # -----------------------------------

  on: (event, callback) ->
    #
    # sets up an event handler for a specific event
    #
    return if not @_validEventName(event)
    return if not @_validCallback(callback)

    #
    # Create a container for event handlers
    #
    @_eventHandlers = {} if @_eventHandlers is null

    #
    # create a new stack for the callbacks if not defined yet
    #
    @_eventHandlers[event] = [] if @_eventHandlers[event] is undefined

    #
    # push the callback onto the stack
    #
    @_eventHandlers[event].push(callback)

  # -----------------------------------

  off: (event, callbackToRemove) ->
    return if @_eventHandlers is null

    if not @_validEventName(event)
      #
      # Drop all listeners
      #
      @_eventHandlers = {}

    else if not @_validCallback(callbackToRemove)
      #
      # Drop all listeners for specified event
      #
      return if @_eventHandlers[event] is undefined

      delete @_eventHandlers[event]

    else
      #
      # Drop only the specified callback from the stack
      #
      return if @_eventHandlers[event] is undefined

      stack = []

      for callback in @_eventHandlers[event]
        stack.push(callback) if callback isnt callbackToRemove

      @_eventHandlers[event] = stack

  # -----------------------------------

  trigger: (event, data) ->
    return if @_eventHandlers is null

    #
    # triggers all listener callbacks of a given event, pass on the data from second argument
    #
    return if not @_validEventName(event)

    return false if @_eventHandlers[event] is undefined

    callback(data) for callback in @_eventHandlers[event]

    return true

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
