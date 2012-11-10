
rippl.Canvas = class Canvas extends ObjectAbstract
  #
  # Default options
  #
  options:
    id: null
    width: 0
    height: 0

  # -----------------------------------

  __isAsset: true

  # -----------------------------------

  changed: false

  # -----------------------------------

  unordered: false

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    if @options.id isnt null
      @_canvas = document.getElementById(@options.id)
      @_width = @options.width = Number @_canvas.width
      @_height = @options.height = Number @_canvas.height
    else
      @_canvas = document.createElement('canvas')
      @_canvas.setAttribute('width', @options.width)
      @_canvas.setAttribute('height', @options.height)
      @_width = @options.width
      @_height = @options.height

    @ctx = @_canvas.getContext('2d')
    @ctx.save()

    @elements = []

  # -----------------------------------

  getDocumentElement: ->
    @_canvas

  # -----------------------------------

  fill: (color) ->
    @ctx.fillStyle = color.toString()
    @ctx.fill()

  # -----------------------------------

  stroke: (width, color) ->
    @ctx.lineWidth = width
    @ctx.strokeStyle = color.toString()
    @ctx.stroke()

  # -----------------------------------

  setShadow: (x, y, blur, color) ->
    x ? x = 0
    y ? y = 0
    blur ? blur = 0
    color ? color = '#000000'

    @ctx.shadowOffsetX = x
    @ctx.shadowOffsetY = y
    @ctx.shadowBlur = blur
    @ctx.shadowColor = color.toString()

  # -----------------------------------

  add: (element) ->
    throw "Tried to add a non-Element to Canvas" if not element.__isElement
    element.canvas = @
    @elements.push(element)
    @touch()
    @unordered = true

    element.on('change', => @touch())
    element.on('change:z', => @unordered = true)

    element

  # -----------------------------------

  remove: (elementToDelete) ->
    filtered = []

    for element in @elements
      if element isnt elementToDelete
        filtered.push(element)
      else
        element.off()
        delete element.canvas

    @elements = filtered
    @touch()

  # -----------------------------------

  wipe: ->
    for element in @elements
      delete element.canvas

    @elements = []
    @touch()

  # -----------------------------------

  reorder: ->
    @elements.sort (a, b) -> a.get('z') - b.get('z')
    @unordered = false

  # -----------------------------------

  touch: ->
    @changed = true

  # -----------------------------------

  clear: ->
    @ctx.clearRect(0, 0, @options.width, @options.height)

  # -----------------------------------

  render: (frameTime) ->
    #
    # Progress transitions
    #
    element.progress(frameTime) for element in @elements

    #
    # Don't redraw if no changes were made
    #
    return if not @changed

    #
    # Reorder elements if needed
    #
    @reorder() if @unordered

    #
    # Clear the canvas
    #
    @clear()

    for element in @elements
      if not element.isHidden()
        @ctx.save()
        element.prepare()
        element.render()
        @ctx.restore()

    @changed = false

  # -----------------------------------

  drawSprite: (asset, x, y, width, height, cropX, cropY) ->
    throw "Canvas.drawSprite: invalid asset" if not asset.__isAsset

    element = asset.getDocumentElement()
    return if not element

    cropX ? cropX = 0
    cropY ? cropY = 0

    x = Math.round(x)
    y = Math.round(y)

    @ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height)

  # -----------------------------------

  rgbaFilter: (filter) ->
    imageData = @ctx.getImageData(0, 0, @options.width, @options.height)

    pixels = imageData.data
    i = 0
    l = pixels.length

    while i < l
      [pixels[i], pixels[i+1], pixels[i+2], pixels[i+3]] = filter(pixels[i], pixels[i+1], pixels[i+2], pixels[i+3])
      i += 4

    @ctx.putImageData(imageData, 0, 0)
