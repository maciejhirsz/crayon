
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

    @points = []
    @options.anchorInPixels = true

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()

    @canvas.ctx.moveTo(@options.rootX - anchor.x, @options.rootY - anchor.y)
    for point in @points
      if point is null
        @canvas.ctx.closePath()
      else
        [x, y, line] = point
        if line
          @canvas.ctx.lineTo(x - anchor.x, y - anchor.y)
        else
          @canvas.ctx.moveTo(x - anchor.x, y - anchor.y)

  # -----------------------------------

  lineTo: (x, y) ->
    @points.push([x, y, true])

  # -----------------------------------

  moveTo: (x, y) ->
    @points.push([x, y, false])

  # -----------------------------------

  close: ->
    @points.push(null)