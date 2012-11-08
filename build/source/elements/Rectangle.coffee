
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
    @canvas.ctx.moveTo(x + width - radius, y)
    @canvas.ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
    @canvas.ctx.lineTo(x + width, y + height - radius)
    @canvas.ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
    @canvas.ctx.lineTo(x + radius, y + height)
    @canvas.ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
    @canvas.ctx.lineTo(x, y + radius)
    @canvas.ctx.quadraticCurveTo(x, y, x + radius, y)
    @canvas.ctx.closePath()