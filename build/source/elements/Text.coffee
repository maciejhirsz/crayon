
rippl.Text = class Text extends Element
  constructor: (options, canvas) ->
    @addDefaults
      label: 'Surface'
      align: 'center' # left|right|center
      baseline: 'middle' # top|hanging|middle|alphabetic|ideographic|bottom
      color: '#000'
      fill: true
      stroke: 0
      strokeColor: '#000'
      italic: false
      bold: false
      size: 12
      font: 'sans-serif'
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

  render: ->
    @canvas.setShadow(@options.shadowX, @options.shadowY, @options.shadowBlur, @options.shadowColor) if @options.shadow

    @canvas.ctx.fillStyle = @options.color.toString() if @options.fill
    @canvas.ctx.textAlign = @options.align
    @canvas.ctx.textBaseline = @options.baseline

    font = []

    font.push('italic') if @options.italic
    font.push('bold') if @options.bold
    font.push("#{@options.size}px")
    font.push(@options.font)

    @canvas.ctx.font = font.join(' ')

    @canvas.ctx.fillText(@options.label, 0, 0) if @options.fill

    if @options.stroke
      @canvas.ctx.lineWidth = @options.stroke
      @canvas.ctx.strokeStyle = @options.strokeColor.toString()
      @canvas.ctx.strokeText(@options.label, 0, 0)
