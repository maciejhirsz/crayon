
rippl.CustomShape = class CustomShape extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      #
      # Set the anchor defaults to 0
      #
      anchorX: 0
      anchorY: 0

    super(options, canvas)

    @path = []
    @options.anchorInPixels = true

  # -----------------------------------

  bind: (canvas) ->
    super(canvas)
    for fragment in @path
      fragment[1].bind(canvas) if fragment isnt null

  # -----------------------------------

  _point: (x, y) ->
    if x.__isPoint and y is undefined
      point = x
    else
      point = new Point(x, y)

    point.bind(@canvas) if @canvas isnt null
    point

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()

    ctx = @canvas.ctx

    ctx.moveTo(-anchor.x, -anchor.y)
    for fragment in @path
      if fragment is null
        ctx.closePath()
      else
        [method, point] = fragment
        ctx[method](point.x - anchor.x, point.y - anchor.y)

  # -----------------------------------

  lineTo: (x, y) ->
    point = @_point(x, y)

    @path.push(['lineTo', point])

    point

  # -----------------------------------

  moveTo: (x, y) ->
    point = @_point(x, y)

    @path.push(['moveTo', point])

    point

  # -----------------------------------

  close: ->
    @path.push(null)

  # -----------------------------------

  _castRay: (a, b, rayY) ->
    # horizontal line matching the ray? Return left-most point
    return Math.min(a.x, b.x) if a.y is b.y is rayY

    # line not crossing ray? Ignore
    return null if a.y > rayY and b.y > rayY
    return null if a.y < rayY and b.y < rayY

    # find intersection
    ((rayY - a.y) / (b.y - a.y)) * (b.x - a.x) + a.x

  # -----------------------------------

  pointOnElement: (x, y) ->
    anchor = @getAnchor()
    options = @options

    x = x - options.position.x
    y = y - options.position.y

    x = x / options.scaleX if options.scaleX isnt 1
    y = y / options.scaleY if options.scaleY isnt 1

    if options.rotation isnt 0
      cos = Math.cos(-options.rotation)
      sin = Math.sin(-options.rotation)

      xrot = cos * x - sin * y
      yrot = sin * x + cos * y

      x = xrot
      y = yrot

    pointA = startPoint = new Point(0, 0)

    count = 0

    # iterate through all lines of the polygon
    for path in @path

      # ending line? Go back to starting point
      if path is null
        pointB = startPoint

      # moving without drawing?
      else if path[0] is 'moveTo' and pointA is startPoint
        pointA = startPoint = path[1]
        continue

      # normal line? Grab new ending point
      else
        pointB = path[1]

      rayX = @_castRay(pointA, pointB, y)

      # increase the count if the line is on the left side
      count += 1 if rayX isnt null and rayX <= x

      # set starting point for the next line
      pointA = pointB

    # odd interesections -> point inside, even interesctions -> point outside
    return !!(count % 2)
