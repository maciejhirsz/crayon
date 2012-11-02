
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
      if @fixedFrames
        iterations = Math.floor((frameTime - @time) / @frameDuration)

        iterations = 1 if iterations < 1

        #
        # Cap iterations
        #
        iterations = 100 if iterations > 100

        for i in [0..iterations-1]
          @trigger('frame', frameTime)
          @time += @frameDuration

      #
      # Handle fluid frames
      #
      else
        @time = frameTime
        @trigger('frame', frameTime)

      #
      # Render all attached Canvas instances
      #
      for canvas in @canvas
        canvas.render(frameTime)

      #
      # Measure time again for maximum precision
      #
      delay = @getTime() - @time

      setTimeout(
        => @tick()
        @frameDuration - delay
      )
