
rippl.Circle = class Circle extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      radius: 0 # radius of the circle
      angle: Math.PI * 2

    super(options, canvas)

    @options.width = @options.radius * 2
    @options.height = @options.radius * 2

  # -----------------------------------

  drawPath: ->
    ctx = @canvas.ctx
    ctx.arc(0, 0, @options.radius, 0, @options.angle, false)
    ctx.lineTo(0, 0) if @options.angle isnt Math.PI * 2
    ctx.closePath()