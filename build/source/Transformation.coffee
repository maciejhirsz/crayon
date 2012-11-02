
  class Transformation extends ObjectAbstract
    startTime: 0

    # -----------------------------------

    finished: false

    # -----------------------------------

    options:
      duration: 1000
      from: null
      to: null
      transition: 'linear'

    # -----------------------------------

    transitions:
      linear: (stage) -> stage
      easeOut: (stage) -> Math.sin(stage * Math.PI / 2)
      easeIn: (stage) -> 1 - Math.sin((1 - stage) * Math.PI / 2)
      easeInOut: (stage) ->
        stage = stage * 2 - 1
        (Math.sin(stage * Math.PI / 2) + 1) / 2
      #elastic: (stage) -> stage

    # -----------------------------------

    constructor: (options) ->
      @setOptions(options)
      @startTime = (new Date).getTime()
      @endTime = @startTime + @options.duration

    # -----------------------------------

    isFinished: ->
      @finished

    # -----------------------------------

    getStage: (time) ->
      stage = (time - @startTime) / @options.duration
      stage = 1 if stage > 1
      stage = 0 if stage < 0

      transition = @transitions[@options.transition]
      if typeof transition is 'function'
        return transition(stage)
      else
        throw "Unknown transition: #{@options.transition}"

    # -----------------------------------

    getValue: (from, to, stage) ->
      (from * (1 - stage)) + (to * stage)

    # -----------------------------------

    progress: (element, time) ->
      return if @finished

      options = {}
      stage = @getStage(time)

      from = @options.from
      to = @options.to

      for option of to
        options[option] = @getValue(from[option], to[option], stage)

      element.set(options)

      #
      # Finish the transformation
      #
      if time >= @endTime
        @finished = true
        #
        # Avoid memleaks
        #
        delete @options.to
        delete @options.from
