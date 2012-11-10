
class Transformation extends ObjectAbstract
  startTime: 0

  # -----------------------------------

  finished: false

  # -----------------------------------

  options:
    duration: 1000
    delay: 0
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
      return new Color(value)

    return value

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    @options.from = {} if @options.from is null
    @options.to = {} if @options.to is null

    @startTime = Date.now() + @options.delay
    @endTime = @startTime + @options.duration

    @

    @options.from[option] = @parseColors(value) for option, value of @options.from
    @options.to[option] = @parseColors(value) for option, value of @options.to

  # -----------------------------------

  isFinished: ->
    @finished

  # -----------------------------------

  getStage: (time) ->
    return 0 if time <= @startTime
    return 1 if time >= @endTime

    stage = (time - @startTime) / @options.duration

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
    if from.__isColor
      return new Color(
        @getValue(from.r, to.r, stage)
        @getValue(from.g, to.g, stage)
        @getValue(from.b, to.b, stage)
        @getValue(from.a, to.a, stage)
      )

    return to

  # -----------------------------------

  progress: (element, time) ->
    return if @finished
    return if time < @startTime

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
      @trigger('end')
