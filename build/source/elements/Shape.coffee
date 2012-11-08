
class Shape extends Element
  constructor: (options, canvas) ->
    @addDefaults
      stroke: 0
      strokeColor: '#000'
      lineCap: 'butt' # butt|round|square
      lineJoin: 'miter' # miter|bevel|round
      erase: false
      fill: true
      color: '#000'
      shadow: false
      shadowX: 0
      shadowY: 0
      shadowBlur: 0
      shadowColor: '#000'

    super(options, canvas)

  # -----------------------------------

  validate: (options) ->
    options.color = @validateColor(options.color) if options.color isnt undefined
    options.strokeColor = @validateColor(options.strokeColor) if options.strokeColor isnt undefined
    options.shadowColor = @validateColor(options.shadowColor) if options.shadowColor isnt undefined

  # -----------------------------------

  drawPath: ->

  # -----------------------------------

  render: ->
    @canvas.setShadow(@options.shadowX, @options.shadowY, @options.shadowBlur, @options.shadowColor) if @options.shadow

    @canvas.ctx.beginPath()

    #
    # Set line properties
    #
    @canvas.ctx.lineCap = @options.lineCap
    @canvas.ctx.lineJoin = @options.lineJoin

    #
    # Draw path
    #
    @drawPath()

    #
    # Erase background before drawing?
    #
    if @options.erase
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
