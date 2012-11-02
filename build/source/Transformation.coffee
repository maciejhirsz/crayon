
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

    parseColors: (value) ->
      if typeof value is 'string' and value[0] is '#'
        color = []
        color.__isColor = true

        if value.length is 7
          color.push(parseInt("0x#{value[1..2]}"))
          color.push(parseInt("0x#{value[3..4]}"))
          color.push(parseInt("0x#{value[5..6]}"))
        else if value.length is 4
          color.push(parseInt("0x#{value[1]+value[1]}"))
          color.push(parseInt("0x#{value[2]+value[2]}"))
          color.push(parseInt("0x#{value[3]+value[3]}"))
        return color
      return value

    # -----------------------------------

    constructor: (options) ->
      @setOptions(options)
      @startTime = (new Date).getTime()
      @endTime = @startTime + @options.duration

      @options.from[option] = @parseColors(value) for option, value of @options.from
      @options.to[option] = @parseColors(value) for option, value of @options.to

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
      #
      # Handle numbers
      #
      if typeof from is 'number'
        return (from * (1 - stage)) + (to * stage)

      #
      # Handle arrays (colors!)
      #
      if typeof from is 'object' and Array.isArray(from)
        value = []
        for v, i in from
          value.push(@getValue(v, to[i], stage))
        return value

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
