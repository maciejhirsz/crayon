
rippl.Text = class Text extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      label: 'Rippl'
      align: 'center' # left|right|center
      baseline: 'middle' # top|hanging|middle|alphabetic|ideographic|bottom
      italic: false
      bold: false
      size: 12
      font: 'sans-serif'

    super(options, canvas)

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
