define (require) ->

  CanvasElementAbstract = require('js/lib/Rippl/CanvasElementAbstract')

  ############################

  class Shape extends CanvasElementAbstract
    constructor: (options, canvas) ->
      @addDefaults
        type: 'rectangle' # rectangle|circle|custom
        #
        # root - for custom shapes position of the first point relative to the anchor
        #
        rootX: 0
        rootY: 0
        #
        # radius - for circle shape the radius of the circle, for rectangle the border radius (rounded rectangle)
        #
        radius: 0
        stroke: 0
        strokeColor: '#000000'
        lineCap: 'butt' # butt|round|square
        lineJoin: 'miter' # miter|bevel|round
        erase: false
        fill: true
        color: '#000000'
        shadow: false
        shadowX: 0
        shadowY: 0
        shadowBlur: 0
        shadowColor: '#000000'

      @points = []

      super(options, canvas)

      @options.anchorInPixels = true if @options.type is 'custom'

    # -----------------------------------

    render: ->
      @canvas.setShadow(@options.shadowX, @options.shadowY, @options.shadowBlur, @options.shadowColor) if @options.shadow

      @canvas.ctx.beginPath()

      anchor = @getAnchor()

      #
      # Set line properties
      #
      @canvas.ctx.lineCap = @options.lineCap
      @canvas.ctx.lineJoin = @options.lineJoin

      #
      # Draw path
      #
      switch @options.type
        when "custom"
          @canvas.ctx.moveTo(@options.rootX - anchor.x, @options.rootY - anchor.y)
          for point in @points
            if point is null
              @canvas.ctx.closePath()
            else
              [x, y] = point
              @canvas.ctx.lineTo(x - anchor.x, y - anchor.y)
        when "circle"
          @canvas.ctx.arc(0, 0, @options.radius, 0, Math.PI * 2, false)
        else
          if @options.radius is 0
            @canvas.ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
          else
            @roundRect(-anchor.x, -anchor.y, @options.width, @options.height, @options.radius)

      #
      # Erase background before drawing?
      #
      if @options.erase
        if @options.type is 'rectangle' and @options.radius is 0
          @canvas.ctx.clearRect(-anchor.x, -anchor.y, @options.width, @options.height)
        else
          @canvas.ctx.save()
          @canvas.ctx.globalCompositeOperation = 'destination-out'
          @canvas.ctx.globalAlpha = 1.0
          @canvas.fill('#000000')
          @canvas.ctx.restore()


      #
      # Fill and stroke if applicable
      #
      @canvas.fill(@options.color) if @options.fill

      @canvas.stroke(@options.stroke, @options.strokeColor) if @options.stroke > 0
      @canvas.ctx.closePath()

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

    # -----------------------------------

    setRoot: (x, y) ->
      @options.rootX = x
      @options.rootY = y
      @canvas.touch()

    # -----------------------------------

    setRadius: (radius) ->
      @options.radius = radius
      @canvas.touch()

    # -----------------------------------

    addPoint: (x, y) ->
      @points.push([x, y])

    # -----------------------------------

    close: ->
      @points.push(null)
