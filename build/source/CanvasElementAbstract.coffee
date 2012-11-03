
class CanvasElementAbstract extends ObjectAbstract
  #
  # Default options
  #
  options:
    x: 0
    y: 0
    z: 0
    anchorX: 0.5
    anchorY: 0.5
    anchorInPixels: false
    width: 0
    height: 0
    alpha: 1.0
    rotation: 0.0
    scaleX: 1.0
    scaleY: 1.0
    hidden: false

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
  __isCanvasElement: true

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)
    @validate(@options)
    @transformStack = []
    @transformCount = 0

  # -----------------------------------
  #
  # Override to validate specific options, such as colors or images
  #
  validate: (options) ->

  # -----------------------------------

  validateColor: (value) ->
    value = new Color(value) if not value.__isColor
    value

  # -----------------------------------

  getAnchor: ->
    if @options.anchorInPixels
      x: @options.anchorX
      y: @options.anchorY
    else
      x: @options.anchorX * @options.width
      y: @options.anchorY * @options.height

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
    return if typeof options.to isnt 'object'

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
  #
  # Used to progress current tranformation stack
  #
  progress: (frameTime) ->
    return if not @transformCount

    newStack = []
    for transform in @transformStack
      transform.progress(@, frameTime)
      newStack.push(transform) if not transform.isFinished()

    @transformStack = newStack
    @transformCount = newStack.length

  # -----------------------------------
  #
  # Used to set alpha, position, scale and rotation on the canvas prior to rendering.
  #
  prepare: ->
    @canvas.setAlpha(@options.alpha) if @options.alpha isnt 1
    @canvas.setPosition(@options.x, @options.y)
    @canvas.setScale(@options.scaleX, @options.scaleY) if @options.scaleX isnt 1 or @options.scaleY isnt 1
    @canvas.setRotation(@options.rotation) if @options.rotation isnt 0

  # -----------------------------------
  #
  # Abstract method that actually draws the element on the canvas, only triggered if the element is not hidden
  #
  render: ->

  # -----------------------------------

  set: (target, value) ->
    if value isnt undefined and typeof target is 'string'
      option = target

      if @options[option] isnt undefined and @options[option] isnt value
        @options[option] = value
        @validate(@options)

        @trigger("change:#{option}")
        @trigger("change")
        return

    change = []

    for option, value of target
      if @options[option] isnt undefined and @options[option] isnt value
        @options[option] = value
        change.push(option)

    if change.length
      @validate(@options)
      @trigger("change:#{option}") for option in change
      @trigger("change")

  # -----------------------------------

  get: (option) ->
    @options[option]
