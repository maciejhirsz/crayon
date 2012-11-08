
rippl.Circle = class Circle extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      radius: 0 # radius of the circle

    super(options, canvas)

    @options.width = @options.radius * 2
    @options.height = @options.radius * 2

  # -----------------------------------

  drawPath: ->
    @canvas.ctx.arc(0, 0, @options.radius, 0, Math.PI * 2, false)