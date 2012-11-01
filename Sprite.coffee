define (require) ->

  CanvasElementAbstract = require('js/lib/Rippl/CanvasElementAbstract')

  ############################

  class Sprite extends CanvasElementAbstract
    #
    # An extra buffer canvas created to handle any filters on the image
    #
    buffer: null

    # -----------------------------------
    #
    # If set to true, the sprite will perform frame animations
    #
    animated: false

    # -----------------------------------

    #
    # Internal counter for animation purposes
    #
    count: 0

    # -----------------------------------

    #
    # List of frames to play in animation
    #
    @playFrames = []

    # -----------------------------------

    #
    # Current frame the animation is on.
    #
    # IMPORTANT: This is an index of @playFrames array, NOT @frames!
    #
    currentFrame: 0

    # -----------------------------------

    constructor: (options, canvas) ->
      @addDefaults
        image: null
        cropX: 0
        cropY: 0

      super(options, canvas)

      #
      # Set of animation frames the sprite supports, can be empty
      #
      @frames = []

    # -----------------------------------

    setFrame: (index) ->
      #
      # Get the properties of the frame
      #
      frame = @frames[index]

      #
      # Change cropping properties to the given frame
      #
      @options.cropX = frame[0]
      @options.cropY = frame[1]
      @removeFilters() # this will also call @canvas.touch()

    # -----------------------------------

    render: ->
      #
      # If sprite is animated we check if current frame matches the animation interval
      #
      if @animated and @count % @animated is 0
        #
        # Switch frame
        #
        @setFrame(@playFrames[@currentFrame])

        #
        # Iterate to the next frame
        #
        @currentFrame += 1
        @currentFrame = 0 if @currentFrame is @playFrames.length

      anchor = @getAnchor()

      #buffer = @canvas.createBuffer
      #  width: @options.width
      #  height: @options.height

      #buffer.drawSprite(@options.image, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
      #buffer.invert()

      #@canvas.drawSprite(buffer.canvas, -anchor.x, -anchor.y, @options.width, @options.height, 0, 0)

      if @buffer?
        @canvas.drawSprite(@buffer.canvas, -anchor.x, -anchor.y, @options.width, @options.height)
      else
        @canvas.drawSprite(@options.image, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)

    # -----------------------------------

    createBuffer: ->
      delete @buffer
      @buffer = @canvas.newCanvas
        width: @options.width
        height: @options.height

      @buffer.drawSprite(@options.image, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

    # -----------------------------------

    clearFilters: ->
      return if not @buffer?
      @buffer.clear()
      @buffer.drawSprite(@options.image, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

    # -----------------------------------

    removeFilters: ->
      delete @buffer
      @buffer = null
      @canvas.touch()

    # -----------------------------------

    invertColorsFilter: ->
      @createBuffer() if not @buffer?
      @buffer.invertColorsFilter()

    # -----------------------------------

    saturationFilter: (saturation) ->
      @createBuffer() if not @buffer?
      @buffer.saturationFilter(saturation)

    # -----------------------------------

    contrastFilter: (contrast) ->
      @createBuffer() if not @buffer?
      @buffer.contrastFilter(contrast)

    # -----------------------------------

    brightnessFilter: (brightness) ->
      @createBuffer() if not @buffer?
      @buffer.brightnessFilter(brightness)

    # -----------------------------------

    gammaFilter: (gamma) ->
      @createBuffer() if not @buffer?
      @buffer.gammaFilter(gamma)

    # -----------------------------------

    hueShiftFilter: (shift) ->
      @createBuffer() if not @buffer?
      @buffer.hueShiftFilter(shift)

    # -----------------------------------

    colorizeFilter: (hue) ->
      @createBuffer() if not @buffer?
      @buffer.colorizeFilter(hue)

    # -----------------------------------

    ghostFilter: (alpha) ->
      @createBuffer() if not @buffer?
      @buffer.ghostFilter(alpha)

    # -----------------------------------

    animate: (interval, from, to) ->
      #
      # Starts animating the sprite
      #
      #   interval - optional (default 1), number of canvas frame renders between each animation frame of the sprite
      #   from - optional (default 0), starting frame of the animation
      #   to - optional (default to last frame), ending frame of the animation
      #

      #
      # Handle the defaults
      #
      interval ? interval = 1
      from = 0 if from is undefined
      to = @frames.length - 1 if to is undefined

      #
      # Create the list of frame indexes to play
      #
      @playFrames = [from..to]

      #
      # Reset the currentFrame to 0
      #
      @currentFrame = 0

      #
      # Start animating if there actually are any frames declared!
      #
      if @playFrames.length
        @count = 0
        @animated = interval

    # -----------------------------------

    stop: ->
      #
      # Stop animation
      #
      @playFrames = []
      @animated = 0

    # -----------------------------------

    addFrame: (cropX, cropY) ->
      #
      # Create animation frame, return the amount of frames already on the sprite
      #
      @frames.push [cropX, cropY]
