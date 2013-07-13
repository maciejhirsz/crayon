
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

  # -----------------------------------

  pointOnElement: (x, y) ->
    anchor = @getAnchor()
    options = @options

    return false if options.angle is 0

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

    return false if Math.sqrt(x*x + y*y) > options.radius
    return false if Math.atan2(x, y) + Math.PI > options.angle

    return true