
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

    super(options, canvas)

  # -----------------------------------

  validate: (options) ->
    if options.src isnt undefined
      if typeof options.src is 'string'
        options.src = asset = rippl.assets.get(options.src)
      else
        asset = options.src

      if not asset.__isLoaded
        asset.on 'loaded', =>
          @canvas.touch() if @canvas
          @calculateFrames()
          @calculateAnchor()
      else
        @calculateFrames()

  # -----------------------------------

  calculateFrames: ->
    src = @options.src
    @options.width = src._width if @options.width is 0
    @options.height = src._height if @options.height is 0
    @_framesModulo = ~~(src._width / @options.width)

  # -----------------------------------

  render: ->
    anchor = @getAnchor()

    if @_useBuffer
      @canvas.drawAsset(@buffer, -anchor.x, -anchor.y, @options.width, @options.height)
    else
      @canvas.drawAsset(@options.src, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  addAnimation: (label, fps, frames, lastFrame) ->
    #
    # Handle fps
    #
    fps = 1 if fps <= 0

    #
    # Handle frame ranges
    #
    if typeof frames is 'number'
      lastFrame = frames if typeof lastFrame isnt 'number'
      frames = [frames..lastFrame]

    animations = @_animationFrames or (@_animations = {})
    animations = @_animations or (@_animations = {})

    animations[label] =
      frames: frames
      frameDuration: 1000 / fps

    @

  # -----------------------------------

  animate: (label) ->
    label ? label = 'idle'
    animation = @_animations[label]
    return if not animation

    @_frames = animation.frames
    @__frameDuration = animation.frameDuration
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

  freeze: ->
    @_animated = false

  # -----------------------------------

  createBuffer: ->
    if not @buffer
      @buffer = new Canvas
        width: @options.width
        height: @options.height
        static: true
    else
      @buffer.clear()

    @buffer.drawAsset(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
    @buffer

  # -----------------------------------

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    @createBuffer()

    @_useBuffer = true
    fn.apply(@buffer, args)
    @canvas.touch()

  # -----------------------------------

  clearFilters: ->
    return if not @buffer?
    @buffer.clear()
    @buffer.drawAsset(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  removeFilter: ->
    delete @buffer
    @buffer = null
    @canvas.touch()
