
rippl.Rectangle = class Rectangle extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      cornerRadius: 0 # radius of rounded corners

    super(options, canvas)

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()
    ctx = @canvas.ctx

    if @options.cornerRadius is 0
      ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
    else
      x = -anchor.x
      y = -anchor.y
      w = @options.width
      h = @options.height
      r = @options.cornerRadius

      ctx.moveTo(x + w - r, y)
      ctx.quadraticCurveTo(x + w, y, x + w, y + r)
      ctx.lineTo(x + w, y + h - r)
      ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
      ctx.lineTo(x + r, y + h)
      ctx.quadraticCurveTo(x, y + h, x, y + h - r)
      ctx.lineTo(x, y + r)
      ctx.quadraticCurveTo(x, y, x + r, y)
      ctx.closePath()
