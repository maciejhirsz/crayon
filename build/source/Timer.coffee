
rippl.Timer = class Timer extends ObjectAbstract
  #
  # Default options
  #
  options:
    fps: 40
    autoStart: true
    #
    # Setting fixed frames to true enforces that every second you get exactly as many 'frame' events triggered as high fps is set
    #
    fixedFrames: false

  # -----------------------------------

  frameDuration: 0

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    @frameDuration = 1000 / @options.fps

    @canvas = []

    @start() if @options.autoStart

  # -----------------------------------

  setFps: (fps) ->
    @options.fps = fps
    @frameDuration = 1000 / @options.fps

  # -----------------------------------

  bind: (canvas) ->
    @canvas.push(canvas)

  # -----------------------------------

  start: ->
    @time = @getTime()

    @timerid = setTimeout(
      => @tick()
      @frameDuration
    )

  # -----------------------------------

  stop: ->
    clearTimeout(@timerid)

  # -----------------------------------

  getTime: ->
    (new Date).getTime()

  # -----------------------------------

  getSeconds: ->
    Math.floor((new Date).getTime() / 1000)

  # -----------------------------------

  tick: ->
    frameTime = @getTime()

    #
    # Handle fixed frames
    #
    if @options.fixedFrames
      iterations = Math.floor((frameTime - @time) / @frameDuration)

      iterations = 1 if iterations < 1

      #
      # Cap iterations
      #
      iterations = 100 if iterations > 100

      for i in [0..iterations-1]
        @time += @frameDuration
        @trigger('frame', frameTime)

    #
    # Handle fluid frames
    #
    else
      @time += @frameDuration
      @trigger('frame', frameTime)

    #
    # Render all attached Canvas instances
    #
    for canvas in @canvas
      canvas.render(frameTime)

    #
    # Measure time again for maximum precision
    #
    postRenderTime = @getTime()
    delay = @time - postRenderTime
    if delay < 0
      delay = 0
      @time = postRenderTime if not @options.fixedFrames

    setTimeout(
      => @tick()
      delay
    )
