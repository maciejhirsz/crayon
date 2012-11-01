
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
  #
  # Moves the element to a different position
  #
  setPosition: (x, y) ->
    if x isnt undefined and y isnt undefined
      @options.x = x
      @options.y = y
      @canvas.touch()

  # -----------------------------------

  getDepth: ->
    @options.z

  # -----------------------------------

  setDepth: (z) ->
    @options.z = z
    @canvas.reorder()
    @canvas.touch()

  # -----------------------------------

  setRotation: (rotation) ->
    @options.rotation = rotation
    @canvas.touch()

  # -----------------------------------

  setScale: (scaleX, scaleY) ->
    scaleY = scaleX if scaleY is undefined
    @options.scaleX = scaleX
    @options.scaleY = scaleY
    @canvas.touch()

  # -----------------------------------

  setAlpha: (alpha) ->
    @options.alpha = alpha
    @canvas.touch()
