
#
# Compatibility for older browsers
#
Date.now = (-> (new @).getTime()) if Date.now is undefined

rippl.Timer = class Timer extends ObjectAbstract
  #
  # Default options
  #
  options:
    fps: 60
    autoStart: true

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

    @time += @frameDuration
    @trigger('frame', frameTime)

    #
    # Render all attached Canvas instances
    #
    canvas.render(frameTime) for canvas in @canvas

    #
    # Measure time again for maximum precision
    #
    postRenderTime = Date.now()
    delay = @time - postRenderTime
    if delay < 0
      delay = 0
      @time = postRenderTime

    setTimeout(
      => @tick()
      delay
    )
