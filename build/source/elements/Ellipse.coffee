
rippl.Ellipse = class Ellipse extends Shape
  drawPath: ->
    anchor = @getAnchor()

    ctx = @canvas.ctx
    x = -anchor.x
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
