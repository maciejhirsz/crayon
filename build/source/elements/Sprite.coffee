
rippl.Sprite = class Sprite extends Element
  #
  # An extra buffer canvas created to handle any filters on the image
  #
  buffer: null

  # -----------------------------------

  _useBuffer: false

  # -----------------------------------

  _animated: false

  # -----------------------------------

  _frameDuration: 0

  # -----------------------------------

  _framesModulo: 0

  # -----------------------------------

  constructor: (options, canvas) ->
    @addDefaults
      src: null
      cropX: 0
      cropY: 0
      fps: 0

    super(options, canvas)

    if @options.fps isnt 0
      @_frameDuration = 1000 / options.fps

  # -----------------------------------

  validate: (options) ->
    if typeof options.src is 'string'
      options.src = asset = rippl.assets.get(options.src)
      if not asset.__isLoaded
        asset.on 'loaded', =>
          @canvas.touch() if @canvas
          @calculateFrames()
      else
        @calculateFrames()

    if typeof options.fps is 'number'
      if options.fps is 0
        @stop()
      else
        @_frameDuration = 1000 / options.fps

  # -----------------------------------

  calculateFrames: ->
    @_framesModulo = ~~(@options.src._width / @options.width)

  # -----------------------------------

  render: ->
    anchor = @getAnchor()

    if @_useBuffer
      @canvas.drawSprite(@buffer, -anchor.x, -anchor.y, @options.width, @options.height)
    else
      @canvas.drawSprite(@options.src, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  addAnimation: (label, frames) ->
    animations = @_animations or (@_animations = {})
    animations[label] = frames
    @

  # -----------------------------------

  animate: (label) ->
    label ? label = 'idle'
    @_frames = @_animations[label]
    @_currentIndex = -1
    @_animationStart = Date.now()
    @_animationEnd = @_animationStart + @_frames.length * @_frameDuration
    @_animated = true

  # -----------------------------------

  progress: (frameTime) ->
    if @_animated and @_framesModulo
      return @animate() if frameTime >= @_animationEnd

      index = ~~((frameTime - @_animationStart) / @_frameDuration)
      if index isnt @_currentIndex
        @_currentIndex = index
        @setFrame(@_frames[index])

    #
    # Progress transformations *AFTER* frame has been set
    #
    super(frameTime)

  # -----------------------------------

  setFrame: (frame) ->
    @_useBuffer = false

    frameX = frame % @_framesModulo
    frameY = ~~(frame / @_framesModulo)

    @options.cropX = frameX * @options.width
    @options.cropY = frameY * @options.height
    @canvas.touch()

  # -----------------------------------

  stop: ->
    @_animated = false

  # -----------------------------------

  createBuffer: ->
    if not @buffer
      @buffer = new Canvas
        width: @options.width
        height: @options.height
    else
      @buffer.clear()

    @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
    @buffer

  # -----------------------------------

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    @createBuffer()

    @_useBuffer = true
    fn.apply(@buffer, args)

  # -----------------------------------

  clearFilters: ->
    return if not @buffer?
    @buffer.clear()
    @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  removeFilter: ->
    delete @buffer
    @buffer = null
    @canvas.touch()
