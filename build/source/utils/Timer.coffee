
#
# Compatibility for older browsers
#
Date.now = (-> (new @).getTime()) if Date.now is undefined

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
    @time = Date.now()

    @timerid = setTimeout(
      => @tick()
      @frameDuration
    )

  # -----------------------------------

  stop: ->
    clearTimeout(@timerid)

  # -----------------------------------

  getSeconds: ->
    ~~(Date.now() / 1000)

  # -----------------------------------

  tick: ->
    frameTime = Date.now()

    #
    # Handle fixed frames
    #
    if @options.fixedFrames
      iterations = ~~((frameTime - @time) / @frameDuration) + 1

      iterations = 1 if iterations < 1

      #
      # Cap iterations
      #
      iterations = 100 if iterations > 100

      @time += @frameDuration * iterations

      while iterations
        @trigger('frame', frameTime)
        iterations -= 1

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
    postRenderTime = Date.now()
    delay = @time - postRenderTime
    if delay < 0
      delay = 0
      @time = postRenderTime if not @options.fixedFrames

    setTimeout(
      => @tick()
      delay
    )
