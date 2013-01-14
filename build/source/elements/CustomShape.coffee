
rippl.CustomShape = class CustomShape extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      #
      # position of the first point relative to the anchor
      #
      rootX: 0
      rootY: 0
      #
      # Set the anchor defaults to 0
      #
      anchorX: 0
      anchorY: 0

    super(options, canvas)

    @path = []
    @options.anchorInPixels = true

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()

    ctx = @canvas.ctx

    ctx.moveTo(@options.rootX - anchor.x, @options.rootY - anchor.y)
    for fragment in @path
      if fragment is null
        ctx.closePath()
      else
        [method, point] = fragment
        ctx[method](point.x - anchor.x, point.y - anchor.y)

  # -----------------------------------

  lineTo: (x, y) ->
    if x.__isPoint and y is undefined
      point = x
    else
      point = new Point(x, y)

    @path.push(['lineTo', point.bind(@canvas)])

    point

  # -----------------------------------

  moveTo: (x, y) ->
    if x.__isPoint and y is undefined
      point = x
    else
      point = new Point(x, y)

    @path.push(['moveTo', point.bind(@canvas)])

    point

  # -----------------------------------

  close: ->
    @path.push(null)