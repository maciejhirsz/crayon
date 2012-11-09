
rippl.Ellipse = class Ellipse extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      radius: 0 # radius of the circle

    super(options, canvas)

    @options.width = @options.radius * 2
    @options.height = @options.radius * 2

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()
    @ellipse(-anchor.x, -anchor.y, @options.width, @options.height)

    ctx = @canvas.ctx
    w = -anchor.x
    y = -anchor.y
    w = @options.width
    h = @options.height

    magic = 0.551784
    ox = (w / 2) * magic  # control point offset horizontal
    oy = (h / 2) * magic  # control point offset vertical
    xe = x + w            # x-end
    ye = y + h            # y-end
    xm = x + w / 2        # x-middle
    ym = y + h / 2        # y-middle

    ctx.moveTo(x, ym)
    ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
    ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
    ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
    ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)
    ctx.closePath()
