
class Element extends ObjectAbstract
  #
  # Default options
  #
  options:
    position: null
    x: 0
    y: 0
    z: 0
    snap: false
    anchorX: 0.5
    anchorY: 0.5
    anchorInPixels: false
    width: 0
    height: 0
    alpha: 1.0
    rotation: 0.0
    scaleX: 1.0
    scaleY: 1.0
    skewX: 0
    skewY: 0
    hidden: false
    input: false
    composition: 'source-over'

  # -----------------------------------

  tranformStack: []

  # -----------------------------------
  #
  # This will be set by the addElement method of the Canvas class
  #
  canvas: null

  # -----------------------------------
  #
  # Used by Canvas class to determine whether elements added with addElement method are instances of this parent class
  #
  __isElement: true

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)
    @validate(@options)
    @transformStack = []
    @transformCount = 0

    #
    # cache anchor position
    #
    @on('change:anchorX change:anchorY change:anchorInPixels', => @calculateAnchor())
    @calculateAnchor()

  # -----------------------------------
  #
  # Override to validate specific options, such as colors or images
  #
  validate: (options) ->
    if options.position?
      options.x = options.position.x
      options.y = options.position.y
      options.position.bind(@canvas) if @canvas isnt null
    else
      if @options.position is null
        @options.position = new Point(@options.x, @options.y)
        @options.position.bind(@canvas) if @canvas isnt null
      @options.position.move(options.x, null) if options.x isnt undefined
      @options.position.move(null, options.y) if options.y isnt undefined

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @options.position.bind(canvas) if @options.position isnt null

  # -----------------------------------

  validateColor: (value) ->
    value = new Color(value) if not value.__isColor
    value

  # -----------------------------------

  calculateAnchor: ->
    if @options.anchorInPixels
      @_anchor =
        x: @options.anchorX
        y: @options.anchorY
    else
      @_anchor =
        x: @options.anchorX * @options.width
        y: @options.anchorY * @options.height

    if @options.snap
      @_anchor.x = Math.round(@_anchor.x)
      @_anchor.y = Math.round(@_anchor.y)

  # -----------------------------------

  getAnchor: ->
    @_anchor

  # -----------------------------------

  hide: ->
    return if @options.hidden
    @options.hidden = true
    @canvas.touch()

  # -----------------------------------

  show: ->
    return if not @options.hidden
    @options.hidden = false
    @canvas.touch()

  # -----------------------------------

  isHidden: ->
    return @options.hidden

  # -----------------------------------

  transform: (options) ->
    #
    # Set starting values if not defined
    #
    options.from ? options.from = {}
    options.to ? options.to = {}

    for option of options.to
      options.from[option] = @options[option] if options.from[option] is undefined

    for option of options.from
      options.to[option] = @options[option] if options.to[option] is undefined

    @validate(options.from)
    @validate(options.to)

    transform = new Transformation(options)

    @transformStack.push(transform)
    @transformCount += 1

    transform

  # -----------------------------------

  stop: ->
    return if not @transformStack
    for transform in @transformStack
      transform.destroy()

    @transformStack = []
    @transformCount = 0

  # -----------------------------------
  #
  # Used to progress current tranformation stack
  #
  progress: (frameTime) ->
    return if not @transformCount

    remove = false

    for transform in @transformStack
      transform.progress(@, frameTime)
      remove = true if transform.isFinished()

    #
    # Second pass to avoid conflicts with anything happening on transformation events
    #
    if remove
      newStack = []
      for transform in @transformStack
        newStack.push(transform) if not transform.isFinished()

      @transformStack = newStack
      @transformCount = newStack.length

  # -----------------------------------
  #
  # Used to set alpha, position, scale and rotation on the canvas prior to rendering.
  #
  prepare: ->
    ctx = @canvas.ctx
    options = @options

    x = options.position.x
    y = options.position.y

    if options.snap
      x = Math.round(x)
      y = Math.round(y)

    ctx.setTransform(options.scaleX, options.skewX, options.skewY, options.scaleY, x, y)
    ctx.globalAlpha = options.alpha if options.alpha isnt 1
    ctx.rotate(options.rotation) if options.rotation isnt 0
    ctx.globalCompositeOperation = options.composition if options.composition isnt 'source-over'

  # -----------------------------------
  #
  # Abstract method that actually draws the element on the canvas, only triggered if the element is not hidden
  #
  render: ->

  # -----------------------------------

  pointOnElement: (x, y) ->
    anchor = @getAnchor()
    options = @options

    x = x - options.position.x
    y = y - options.position.y

    return false if options.scaleX is 0 or options.scaleY is 0

    x = x / options.scaleX if options.scaleX isnt 1
    y = y / options.scaleY if options.scaleY isnt 1

    if options.rotation isnt 0
      cos = Math.cos(-options.rotation)
      sin = Math.sin(-options.rotation)

      xrot = cos * x - sin * y
      yrot = sin * x + cos * y

      x = xrot
      y = yrot

    return false if x < -anchor.x or x > options.width - anchor.x
    return false if y < -anchor.y or y > options.height - anchor.y

    return true

  # -----------------------------------

  delegateInputEvent: (type, x, y) ->
    return false if @options.input is false
    return false if @pointOnElement(x, y) is false

    @trigger(type)

    return true

  # -----------------------------------

  set: (target, value) ->
    if value isnt undefined and typeof target is 'string'
      options = {}
      options[target] = value
      target = options

    change = []

    @validate(target)

    for option, value of target
      if @options[option] isnt undefined and @options[option] isnt value
        @options[option] = value
        change.push(option)

    if change.length
      @trigger("change:#{option}") for option in change
      @trigger("change")

  # -----------------------------------

  get: (option) ->
    @options[option]
