
rippl.Rectangle = class Rectangle extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      radius: 0 # radius of rounded corners

    super(options, canvas)

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()

    if @options.radius is 0
      @canvas.ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
    else
      @roundRect(-anchor.x, -anchor.y, @options.width, @options.height, @options.radius)

  # -----------------------------------

  roundRect: (x, y, width, height, radius) ->
    ctx = @canvas.ctx
    ctx.moveTo(x + width - radius, y)
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
    ctx.lineTo(x + width, y + height - radius)
    ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
    ctx.lineTo(x + radius, y + height)
    ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
    ctx.lineTo(x, y + radius)
    ctx.quadraticCurveTo(x, y, x + radius, y)
    ctx.closePath()