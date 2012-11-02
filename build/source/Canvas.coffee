
class Canvas extends ObjectAbstract
  #
  # Default options
  #
  options:
    id: null
    width: 0
    height: 0

  # -----------------------------------

  changed: false

  # -----------------------------------

  unordered: false

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    if @options.id isnt null
      @canvas = document.getElementById(@options.id)
      @options.width = Number @canvas.width
      @options.height = Number @canvas.height
    else
      @canvas = document.createElement('canvas')
      @canvas.setAttribute('width', @options.width)
      @canvas.setAttribute('height', @options.height)

    @ctx = @canvas.getContext('2d')
    @ctx.save()

    @elements = []

  # -----------------------------------

  getCanvas: ->
    @canvas

  # -----------------------------------

  newCanvas: (options) ->
    return new Canvas(options)

  # -----------------------------------

  createImage: (url, callback) ->
    image = new Image
    image.onload = -> callback(image)
    image.src = url

  # -----------------------------------

  fill: (color) ->
    @ctx.fillStyle = color
    @ctx.fill()

  # -----------------------------------

  stroke: (width, color) ->
    @ctx.lineWidth = width
    @ctx.strokeStyle = color
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
    @ctx.shadowColor = color

  # -----------------------------------

  setScale: (x, y) ->
    @ctx.scale(x, y)

  # -----------------------------------

  setAlpha: (alpha) ->
    @ctx.globalAlpha = alpha

  # -----------------------------------

  setRotation: (rotation) ->
    @ctx.rotate(rotation)

  # -----------------------------------

  setPosition: (x, y) ->
    @ctx.translate(x, y)

  # -----------------------------------

  addElement: (element) ->
    throw "Tried to add a non-CanvasElement to Canvas" if not element.__isCanvasElement
    element.canvas = @
    @elements.push(element)
    @touch()
    @unordered = true

    element.on('change', => @touch())
    element.on('change:z', => @unordered = true)

    element

  # -----------------------------------

  createSprite: (options) ->
    @addElement(new Sprite(options))

  # -----------------------------------

  createShape: (options) ->
    @addElement(new Shape(options))

  # -----------------------------------

  createText: (options) ->
    @addElement(new Text(options))

  # -----------------------------------

  removeElement: (elementToDelete) ->
    filtered = []

    for element in @elements
      if element isnt elementToDelete
        filtered.push(element)
      else
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
        element.prepare(frameTime)
        element.render()
        @ctx.restore()

    @changed = false

  # -----------------------------------

  drawSprite: (image, x, y, width, height, cropX, cropY) ->
    cropX ? cropX = 0
    cropY ? cropY = 0

    @ctx.drawImage(image, cropX, cropY, width, height, x, y, width, height)

  # -----------------------------------

  toDataUrl: ->
    @canvas.toDataURL()

  # -----------------------------------
  #
  # Start: Filter helpers
  #
  # -----------------------------------

  rgbToLuma: (r, g, b) ->
    0.30 * r + 0.59 * g + 0.11 * b

  # -----------------------------------

  rgbToChroma: (r, g, b) ->
    Math.max(r, g, b) - Math.min(r, g, b)

  # -----------------------------------

  rgbToLumaChromaHue: (r, g, b) ->
    luma = @rgbToLuma(r, g, b)
    chroma = @rgbToChroma(r, g, b)

    if chroma is 0
      hprime = 0
    else if r is max
      hprime = ((g - b) / chroma) % 6
    else if g is max
      hprime = ((b - r) / chroma) + 2
    else if b is max
      hprime = ((r - g) / chroma) + 4

    hue = hprime * (Math.PI / 3)
    [luma, chroma, hue]

  # -----------------------------------

  lumaChromaHueToRgb: (luma, chroma, hue) ->
    hprime = hue / (Math.PI / 3)
    x = chroma * (1 - Math.abs(hprime % 2 - 1))
    sextant = Math.floor(hprime)

    switch sextant
      when 0
        r = chroma
        g = x
        b = 0
      when 1
        r = x
        g = chroma
        b = 0
      when 2
        r = 0
        g = chroma
        b = x
      when 3
        r = 0
        g = x
        b = chroma
      when 4
        r = x
        g = 0
        b = chroma
      when 5
        r = chroma
        g = 0
        b = x

    component = luma - @rgbToLuma(r, g, b)

    r += component
    g += component
    b += component
    [r,g,b]

  # -----------------------------------
  #
  # End: Filter helpers
  #
  # Start: Filters
  #
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

  # -----------------------------------

  invertColorsFilter: ->
    @rgbaFilter (r, g, b, a) ->
      r = 255 - r
      g = 255 - g
      b = 255 - b
      [r, g, b, a]

  # -----------------------------------

  saturationFilter: (saturation) ->
    saturation += 1
    grayscale = 1 - saturation

    @rgbaFilter (r, g, b, a) =>
      luma = @rgbToLuma(r, g, b)

      r = r * saturation + luma * grayscale
      g = g * saturation + luma * grayscale
      b = b * saturation + luma * grayscale
      [r, g, b, a]

  # -----------------------------------

  contrastFilter: (contrast) ->
    gray = -contrast
    original = 1 + contrast

    @rgbaFilter (r, g, b, a) ->
      r = r * original + 127 * gray
      g = g * original + 127 * gray
      b = b * original + 127 * gray
      [r, g, b, a]

  # -----------------------------------

  brightnessFilter: (brightness) ->
    change = 255 * brightness

    @rgbaFilter (r, g, b, a) ->
      r += change
      g += change
      b += change
      [r, g, b, a]

  # -----------------------------------

  gammaFilter: (gamma) ->
    gamma += 1

    @rgbaFilter (r, g, b, a) ->
      r *= gamma
      g *= gamma
      b *= gamma
      [r, g, b, a]

  # -----------------------------------

  hueShiftFilter: (shift) ->
    fullAngle = Math.PI * 2
    shift = shift % fullAngle

    @rgbaFilter (r, g, b, a) =>
      [luma, chroma, hue] = @rgbToLumaChromaHue(r, g, b)

      hue = (hue + shift) % fullAngle
      hue += fullAngle if hue < 0

      [r, g, b] = @lumaChromaHueToRgb(luma, chroma, hue)
      [r, g, b, a]

  # -----------------------------------

  colorizeFilter: (hue) ->
    hue = hue % (Math.PI * 2)
    @rgbaFilter (r, g, b, a) =>
      luma = @rgbToLuma(r, g, b)
      chroma = @rgbToChroma(r, g, b)
      [r, g, b] = @lumaChromaHueToRgb(luma, chroma, hue)
      [r, g, b, a]

  # -----------------------------------

  ghostFilter: (alpha) ->
    opacity = 1 - alpha
    @rgbaFilter (r, g, b, a) =>
      luma = @rgbToLuma(r, g, b)
      a = (a / 255) * (luma * alpha + 255 * opacity)
      [r, g, b, a]

  # -----------------------------------
  #
  # End: Filters
  #
  # -----------------------------------
