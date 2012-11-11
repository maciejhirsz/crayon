
#
# Compatibility for older browsers
#
Date.now = (-> (new @).getTime()) if Date.now is undefined

if window.requestAnimationFrame is undefined
  vendors = ['ms', 'moz', 'webkit', 'o']
  for vendor in vendors
    if window[vendor+'RequestAnimationFrame']
      window.requestAnimationFrame = window[vendor+'RequestAnimationFrame']
      window.cancelAnimationFrame = window[vendor+'CancelAnimationFrame'] || window[vendor+'CancelRequestAnimationFrame']

class Timer extends ObjectAbstract
  #
  # Default options
  #
  options:
    fps: 60

  # -----------------------------------

  _useAnimationFrame: false

  # -----------------------------------

  frameDuration: 0

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    @frameDuration = 1000 / @options.fps

    #@_useAnimationFrame = true if window.requestAnimationFrame and @options.fps is 60

    @canvas = []

    @start()

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

    if @_useAnimationFrame
      @timerid = window.requestAnimationFrame (time) => @tick(time)
    else
      @timerid = setTimeout(
        => @tickLegacy()
        @frameDuration
      )

  # -----------------------------------

  stop: ->
    if @_useAnimationFrame
      window.cancelAnimationFrame(@timerid)
    else
      window.clearTimeout(@timerid)

  # -----------------------------------

  getSeconds: ->
    ~~(Date.now() / 1000)

  # -----------------------------------

  tick: (frameTime) ->
    frameTime = Date.now if not frameTime

    @trigger('frame', frameTime)

    canvas.render(frameTime) for canvas in @canvas

    @timerid = window.requestAnimationFrame (time) => @tick(time)

  # -----------------------------------

  tickLegacy: ->
    frameTime = Date.now()

    @time += @frameDuration
    @trigger('frame', frameTime)

    canvas.render(frameTime) for canvas in @canvas

    #
    # Measure time again for maximum precision
    #
    postRenderTime = Date.now()
    delay = @time - postRenderTime
    if delay < 0
      delay = 0
      @time = postRenderTime

    @timerid = window.setTimeout(
      => @tickLegacy()
      delay
    )

#
# Initialize a global timer
#
rippl.timer = new Timer