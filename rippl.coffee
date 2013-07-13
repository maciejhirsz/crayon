###
(c) 2012-2013 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
###

window.rippl = rippl = {}

# =============================================
#
# Begin contents of ObjectAbstract.coffee
#
# =============================================

rippl.ObjectAbstract = class ObjectAbstract
  #
  # Default options
  #
  options: {}

  # -----------------------------------

  _eventSeparator: new RegExp("\\s+")

  # -----------------------------------

  _validEventName: (event) ->
    return false if typeof event isnt 'string'
    return true

  # -----------------------------------

  _validCallback: (callback) ->
    return false if typeof callback isnt 'function'
    return true

  # -----------------------------------

  on: (events, callback) ->
    #
    # sets up an event handler for a specific event
    #
    return @ if not @_validCallback(callback)

    for event in events.split(@_eventSeparator)
      #
      # Create a container for event handlers
      #
      handlers = @_eventHandlers or (@_eventHandlers = {})
      #@_eventHandlers = {} if @_eventHandlers is null

      #
      # create a new stack for the callbacks if not defined yet
      #
      handlers[event] = [] if handlers[event] is undefined

      #
      # push the callback onto the stack
      #
      handlers[event].push(callback)

    return @

  # -----------------------------------

  once: (event, callback) ->
    padding = (args...) =>
      @off(event, padding)
      callback.apply(@, args)

    @on(event, padding)

  # -----------------------------------

  off: (event, callbackToRemove) ->
    return @ if not handlers = @_eventHandlers

    args = arguments.length

    if args is 0
      #
      # Drop all listeners
      #
      @_eventHandlers = {}

    else if args is 1
      #
      # Drop all listeners for specified event
      #
      return @ if handlers[event] is undefined

      delete handlers[event]

    else if event is null
      #
      # Drop callback from all handlers
      #
      for event of handlers
        stack = []

        for callback in handlers[event]
          stack.push(callback) if callback isnt callbackToRemove

        handlers[event] = stack

    else
      #
      # Drop only the specified callback from the stack
      #
      return @ if handlers[event] is undefined

      stack = []

      for callback in handlers[event]
        stack.push(callback) if callback isnt callbackToRemove

      handlers[event] = stack

    return @

  # -----------------------------------

  trigger: (event, args...) ->
    return @ if not handlers = @_eventHandlers

    #
    # triggers all listener callbacks of a given event, pass on the data from second argument
    #
    return @ if not @_validEventName(event)

    return @ if handlers[event] is undefined

    callback.apply(@, args) for callback in handlers[event]

    return @

  # -----------------------------------

  addDefaults: (defaults) ->
    #
    # Adds new defaults
    #
    if @options isnt undefined
      for option of @options
        defaults[option] = @options[option] if defaults[option] is undefined

    @options = defaults

  # -----------------------------------

  setOptions: (options) ->
    #
    # Set the @option property with new options or use defaults
    #
    if options isnt undefined

      defaults = @options
      @options = {}

      for option of defaults
        if options[option] isnt undefined
          @options[option] = options[option]
        else
          @options[option] = defaults[option]

      return true

    return false

# =============================================
#
# End contents of ObjectAbstract.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/Timer.coffee
#
# =============================================

#
# Compatibility for older browsers
#
Date.now = (-> (new @).getTime()) if Date.now is undefined

if window.requestAnimationFrame is undefined
  vendors = ['ms', 'moz', 'webkit', 'o']
  for vendor in vendors
    if window[vendor+'RequestAnimationFrame']
      window.requestAnimationFrame = window[vendor+'RequestAnimationFrame']
      window.cancelAnimationFrame = window[vendor+'CancelAnimationFrame'] || window[vendor+'CancelRequestAnimationFrame']

class Timer extends ObjectAbstract
  _useAnimationFrame: false

  # -----------------------------------

  _frameDuration: 1000 / 60

  # -----------------------------------

  constructor: ->
    @_useAnimationFrame = true if window.requestAnimationFrame

    @canvas = []

    @start()

  # -----------------------------------

  bind: (canvas) ->
    @canvas.push(canvas)

  # -----------------------------------

  start: ->
    @time = Date.now()

    if @_useAnimationFrame
      @timerid = window.requestAnimationFrame (time) => @tick(time)
    else
      @timerid = setTimeout(
        => @tickLegacy()
        @_frameDuration
      )

  # -----------------------------------

  stop: ->
    if @_useAnimationFrame
      window.cancelAnimationFrame(@timerid)
    else
      window.clearTimeout(@timerid)

  # -----------------------------------

  getSeconds: ->
    ~~(Date.now() / 1000)

  # -----------------------------------

  tick: (frameTime) ->
    frameTime = Date.now() # Chrome 24 and IE 10 band aid, need to find a better solution

    @trigger('frame', frameTime)

    canvas.render(frameTime) for canvas in @canvas

    @timerid = window.requestAnimationFrame (time) => @tick(time)

  # -----------------------------------

  tickLegacy: ->
    frameTime = Date.now()

    @time += @_frameDuration
    @trigger('frame', frameTime)

    canvas.render(frameTime) for canvas in @canvas

    #
    # Measure time again for maximum precision
    #
    postRenderTime = Date.now()
    delay = @time - postRenderTime
    if delay < 0
      delay = 0
      @time = postRenderTime

    @timerid = window.setTimeout(
      => @tickLegacy()
      delay
    )

#
# Initialize a global timer
#
rippl.timer = new Timer
# =============================================
#
# End contents of utils/Timer.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/Color.coffee
#
# =============================================

rippl.Color = class Color
  r: 255
  g: 255
  b: 255
  a: 1

  # -----------------------------------

  __isColor: true

  # -----------------------------------

  string: 'rgba(255,255,255,1)'

  # -----------------------------------

  rgbaPattern: new RegExp('\\s*rgba\\(\\s*(\\d{1,3})\\s*\\,\\s*(\\d{1,3})\\s*\\,\\s*(\\d{1,3})\\s*\\,\\s*(\\d+\.?\\d*|\\d*\.?\\d+)\s*\\)\\s*', 'i')

  # -----------------------------------

  constructor: (r, g, b, a) ->
    if typeof r is 'string'
      if r[0] is '#'
        hash = r

        l = hash.length
        if l is 7
          r = parseInt(hash[1..2], 16)
          g = parseInt(hash[3..4], 16)
          b = parseInt(hash[5..6], 16)
        else if l is 4
          r = parseInt(hash[1]+hash[1], 16)
          g = parseInt(hash[2]+hash[2], 16)
          b = parseInt(hash[3]+hash[3], 16)
        else
          throw "Invalid color string: "+hash
      else if matches = r.match(@rgbaPattern)
        r = Number matches[1]
        g = Number matches[2]
        b = Number matches[3]
        a = Number matches[4]
      else
        throw "Invalid color string: "+r

    @set(r, g, b, a)

  # -----------------------------------

  set: (r, g, b, a) ->
    #
    # Tilde is way more performant than Math.floor
    #
    @r = ~~r
    @g = ~~g
    @b = ~~b
    @a = a if a isnt undefined
    @cacheString()

  # -----------------------------------

  cacheString: ->
    @string = "rgba(#{@r},#{@g},#{@b},#{@a})"

  # -----------------------------------

  toString: ->
    @string

# =============================================
#
# End contents of utils/Color.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/Point.coffee
#
# =============================================

rippl.Point = class Point extends ObjectAbstract
  x: 0
  y: 0

  # -----------------------------------

  __isPoint: true

  # -----------------------------------

  canvas: null

  # -----------------------------------

  constructor: (x, y) ->
    @x = x
    @y = y

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @

  # -----------------------------------

  move: (x, y) ->
    @x = x if x isnt null
    @y = y if y isnt null
    @canvas.touch() if @canvas isnt null
    @trigger('move', @)
    @

# =============================================
#
# End contents of utils/Point.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/RelativePoint.coffee
#
# =============================================

rippl.RelativePoint = class RelativePoint extends ObjectAbstract
  x: 0
  y: 0

  # -----------------------------------

  vectorX: 0
  vectorY: 0

  # -----------------------------------

  root: null

  # -----------------------------------

  __isPoint: true

  # -----------------------------------

  canvas: null

  # -----------------------------------

  constructor: (x, y, root) ->
    throw "Tried to create a RelativePoint with invalid root Point" if not root.__isPoint

    @x = x + root.x
    @y = y + root.y
    @vectorX = x
    @vectorY = y
    @root = root

    root.on 'move', (root) =>
      @x = root.x + @vectorX
      @y = root.y + @vectorY
      @trigger('move', @)

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @

  # -----------------------------------

  move: (x, y) ->
    if x isnt null
      @x = @root.x + x
      @vectorX = x

    if y isnt null
      @y = @root.y + y
      @vectorY = y

    @canvas.touch() if @canvas isnt null
    @trigger('move', @)
    @

# =============================================
#
# End contents of utils/RelativePoint.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/Transformation.coffee
#
# =============================================

class Transformation extends ObjectAbstract
  startTime: 0

  # -----------------------------------

  finished: false

  # -----------------------------------

  options:
    duration: 1000
    delay: 0
    from: null
    to: null
    custom: null
    transition: 'linear'

  # -----------------------------------

  transitions:
    linear: (stage) -> stage
    easeOut: (stage) -> Math.sin(stage * Math.PI / 2)
    easeIn: (stage) -> 1 - Math.sin((1 - stage) * Math.PI / 2)
    easeInOut: (stage) ->
      stage = stage * 2 - 1
      (Math.sin(stage * Math.PI / 2) + 1) / 2
    #elastic: (stage) -> stage

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    @options.from = {} if @options.from is null
    @options.to = {} if @options.to is null

    @startTime = Date.now() + @options.delay
    @endTime = @startTime + @options.duration

  # -----------------------------------

  isFinished: ->
    @finished

  # -----------------------------------

  getStage: (time) ->
    return 0 if time <= @startTime
    return 1 if time >= @endTime

    stage = (time - @startTime) / @options.duration

    transition = @transitions[@options.transition]
    if typeof transition is 'function'
      return transition(stage)
    else
      throw "Unknown transition: #{@options.transition}"

  # -----------------------------------

  getValue: (from, to, stage) ->
    #
    # Handle numbers
    #
    if typeof from is 'number'
      return (from * (1 - stage)) + (to * stage)

    #
    # Handle arrays (colors!)
    #
    if from.__isColor
      return new Color(
        @getValue(from.r, to.r, stage)
        @getValue(from.g, to.g, stage)
        @getValue(from.b, to.b, stage)
        @getValue(from.a, to.a, stage)
      )

    return to

  # -----------------------------------

  progress: (element, time) ->
    return if @finished
    return if time < @startTime

    options = {}
    stage = @getStage(time)

    @options.custom.call(element, stage) if typeof @options.custom is 'function'

    from = @options.from
    to = @options.to

    for option of to
      options[option] = @getValue(from[option], to[option], stage)

    element.set(options)

    #
    # Finish the transformation
    #
    if time >= @endTime
      @destroy()
      @finished = true
      @trigger('end')

  # -----------------------------------

  destroy: ->
    #
    # Avoid memleaks
    #
    delete @options.to
    delete @options.from

# =============================================
#
# End contents of utils/Transformation.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/ImageAsset.coffee
#
# =============================================

rippl.ImageAsset = class ImageAsset extends ObjectAbstract
  __isAsset: true

  # -----------------------------------

  __isLoaded: false

  # -----------------------------------

  _width: 0

  # -----------------------------------

  _height: 0

  # -----------------------------------

  constructor: (url) ->
    image = new Image
    image.src = url
    image.onload = =>
      @_width = width = image.naturalWidth
      @_height = height = image.naturalHeight

      @_cache = new Canvas
        width: width
        height: height
        static: true

      @_cache.drawRaw(image, 0, 0, width, height)
      @_image = @_cache.getDocumentElement()

      @__isLoaded = true
      @trigger('loaded')
      @off('loaded') # loaded happens only once

  # -----------------------------------

  getPixelAlpha: (x, y) ->
    return 0 if not @__isLoaded
    @_cache.getPixelAlpha(x, y)

  # -----------------------------------

  getDocumentElement: ->
    return @_image if @__isLoaded
    return null

# =============================================
#
# End contents of utils/ImageAsset.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/assets.coffee
#
# =============================================

rippl.assets =
  _assets: {}

  # -----------------------------------

  get: (url) ->
    return @_assets[url] if @_assets[url] isnt undefined

    return @_assets[url] = new ImageAsset(url)

  # -----------------------------------

  define: (url, dataurl) ->
    @_assets[url] = new ImageAsset(dataurl)

  # -----------------------------------

  preload: (urls, callback) ->
    urls = [urls] if typeof urls is 'string'

    count = urls.length

    for url in urls
      asset = @get(url)
      if asset.__isLoaded
        count -= 1
        callback() if count is 0 and typeof callback is 'function'

      else
        asset.on 'loaded', ->
          count -= 1
          callback() if count is 0 and typeof callback is 'function'

# =============================================
#
# End contents of utils/assets.coffee
#
# =============================================

# =============================================
#
# Begin contents of utils/filters.coffee
#
# =============================================
((rippl) ->

  rgbToLuma = (r, g, b) ->
    0.30 * r + 0.59 * g + 0.11 * b

  # -----------------------------------

  rgbToChroma = (r, g, b) ->
    Math.max(r, g, b) - Math.min(r, g, b)

  # -----------------------------------

  rgbToLumaChromaHue = (r, g, b) ->
    luma = rgbToLuma(r, g, b)
    chroma = rgbToChroma(r, g, b)

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

  lumaChromaHueToRgb = (luma, chroma, hue) ->
    hprime = hue / (Math.PI / 3)
    x = chroma * (1 - Math.abs(hprime % 2 - 1))
    sextant = ~~hprime

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

    component = luma - rgbToLuma(r, g, b)

    r += component
    g += component
    b += component
    [r,g,b]

  #######################

  rippl.filters =
    colorOverlay: (color) ->
      color = new Color(color) if not color.__isColor

      ctx = @ctx
      ctx.save()
      ctx.globalCompositeOperation = 'source-atop'
      ctx.fillStyle = color.toString()
      ctx.fillRect(0, 0, @_width, @_height)
      ctx.restore()

    # -----------------------------------

    invertColors: ->
      @rgbaFilter (r, g, b, a) ->
        r = 255 - r
        g = 255 - g
        b = 255 - b
        [r, g, b, a]

    # -----------------------------------

    saturation: (saturation) ->
      saturation += 1
      grayscale = 1 - saturation

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)

        r = r * saturation + luma * grayscale
        g = g * saturation + luma * grayscale
        b = b * saturation + luma * grayscale
        [r, g, b, a]

    # -----------------------------------

    contrast: (contrast) ->
      gray = -contrast
      original = 1 + contrast

      @rgbaFilter (r, g, b, a) ->
        r = r * original + 127 * gray
        g = g * original + 127 * gray
        b = b * original + 127 * gray
        [r, g, b, a]

    # -----------------------------------

    brightness: (brightness) ->
      change = 255 * brightness

      @rgbaFilter (r, g, b, a) ->
        r += change
        g += change
        b += change
        [r, g, b, a]

    # -----------------------------------

    gamma: (gamma) ->
      gamma += 1

      @rgbaFilter (r, g, b, a) ->
        r *= gamma
        g *= gamma
        b *= gamma
        [r, g, b, a]

    # -----------------------------------

    hueShift: (shift) ->
      fullAngle = Math.PI * 2
      shift = shift % fullAngle

      @rgbaFilter (r, g, b, a) =>
        [luma, chroma, hue] = rgbToLumaChromaHue(r, g, b)

        hue = (hue + shift) % fullAngle
        hue += fullAngle if hue < 0

        [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        [r, g, b, a]

    # -----------------------------------

    colorize: (hue) ->
      hue = hue % (Math.PI * 2)

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)
        chroma = rgbToChroma(r, g, b)
        [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        [r, g, b, a]

    # -----------------------------------

    ghost: (alpha, hue) ->
      opacity = 1 - alpha

      @rgbaFilter (r, g, b, a) ->
        luma = rgbToLuma(r, g, b)
        if typeof hue is 'number'
          chroma = rgbToChroma(r, g, b)
          [r, g, b] = lumaChromaHueToRgb(luma, chroma, hue)
        a = (a / 255) * (luma * alpha + 255 * opacity)
        [r, g, b, a]

)(rippl)
# =============================================
#
# End contents of utils/filters.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Element.coffee
#
# =============================================

class Element extends ObjectAbstract
  #
  # Default options
  #
  options:
    position: null
    x: 0
    y: 0
    z: 0
    snap: false
    anchorX: 0.5
    anchorY: 0.5
    anchorInPixels: false
    width: 0
    height: 0
    alpha: 1.0
    rotation: 0.0
    scaleX: 1.0
    scaleY: 1.0
    skewX: 0
    skewY: 0
    hidden: false
    input: false
    composition: 'source-over'

  # -----------------------------------

  tranformStack: []

  # -----------------------------------
  #
  # This will be set by the addElement method of the Canvas class
  #
  canvas: null

  # -----------------------------------
  #
  # Used by Canvas class to determine whether elements added with addElement method are instances of this parent class
  #
  __isElement: true

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)
    @validate(@options)
    @transformStack = []
    @transformCount = 0

    #
    # cache anchor position
    #
    @on('change:anchorX change:anchorY change:anchorInPixels', => @calculateAnchor())
    @calculateAnchor()

  # -----------------------------------
  #
  # Override to validate specific options, such as colors or images
  #
  validate: (options) ->
    if options.position?
      options.x = options.position.x
      options.y = options.position.y
      options.position.bind(@canvas) if @canvas isnt null
    else
      if @options.position is null
        @options.position = new Point(@options.x, @options.y)
        @options.position.bind(@canvas) if @canvas isnt null
      @options.position.move(options.x, null) if options.x isnt undefined
      @options.position.move(null, options.y) if options.y isnt undefined

  # -----------------------------------

  bind: (canvas) ->
    @canvas = canvas
    @options.position.bind(canvas) if @options.position isnt null

  # -----------------------------------

  validateColor: (value) ->
    value = new Color(value) if not value.__isColor
    value

  # -----------------------------------

  calculateAnchor: ->
    if @options.anchorInPixels
      @_anchor =
        x: @options.anchorX
        y: @options.anchorY
    else
      @_anchor =
        x: @options.anchorX * @options.width
        y: @options.anchorY * @options.height

    if @options.snap
      @_anchor.x = Math.round(@_anchor.x)
      @_anchor.y = Math.round(@_anchor.y)

  # -----------------------------------

  getAnchor: ->
    @_anchor

  # -----------------------------------

  hide: ->
    return if @options.hidden
    @options.hidden = true
    @canvas.touch()

  # -----------------------------------

  show: ->
    return if not @options.hidden
    @options.hidden = false
    @canvas.touch()

  # -----------------------------------

  isHidden: ->
    return @options.hidden

  # -----------------------------------

  transform: (options) ->
    #
    # Set starting values if not defined
    #
    options.from ? options.from = {}
    options.to ? options.to = {}

    for option of options.to
      options.from[option] = @options[option] if options.from[option] is undefined

    for option of options.from
      options.to[option] = @options[option] if options.to[option] is undefined

    @validate(options.from)
    @validate(options.to)

    transform = new Transformation(options)

    @transformStack.push(transform)
    @transformCount += 1

    transform

  # -----------------------------------

  stop: ->
    return if not @transformStack
    for transform in @transformStack
      transform.destroy()

    @transformStack = []
    @transformCount = 0

  # -----------------------------------
  #
  # Used to progress current tranformation stack
  #
  progress: (frameTime) ->
    return if not @transformCount

    remove = false

    for transform in @transformStack
      transform.progress(@, frameTime)
      remove = true if transform.isFinished()

    #
    # Second pass to avoid conflicts with anything happening on transformation events
    #
    if remove
      newStack = []
      for transform in @transformStack
        newStack.push(transform) if not transform.isFinished()

      @transformStack = newStack
      @transformCount = newStack.length

  # -----------------------------------
  #
  # Used to set alpha, position, scale and rotation on the canvas prior to rendering.
  #
  prepare: ->
    ctx = @canvas.ctx
    options = @options

    x = options.position.x
    y = options.position.y

    if options.snap
      x = Math.round(x)
      y = Math.round(y)

    ctx.setTransform(options.scaleX, options.skewX, options.skewY, options.scaleY, x, y)
    ctx.globalAlpha = options.alpha if options.alpha isnt 1
    ctx.rotate(options.rotation) if options.rotation isnt 0
    ctx.globalCompositeOperation = options.composition if options.composition isnt 'source-over'

  # -----------------------------------
  #
  # Abstract method that actually draws the element on the canvas, only triggered if the element is not hidden
  #
  render: ->

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

    return false if x <= -anchor.x or x > options.width - anchor.x
    return false if y <= -anchor.y or y > options.height - anchor.y

    return true

  # -----------------------------------

  delegateInputEvent: (type, x, y) ->
    options = @options

    return false if options.input is false
    return false if options.hidden is true
    return false if options.alpha is 0
    return false if options.scaleX is 0 or options.scaleY is 0
    return false if @pointOnElement(x, y) is false

    @trigger(type)

    return true

  # -----------------------------------

  set: (target, value) ->
    if value isnt undefined and typeof target is 'string'
      options = {}
      options[target] = value
      target = options

    change = []

    @validate(target)

    for option, value of target
      if @options[option] isnt undefined and @options[option] isnt value
        @options[option] = value
        change.push(option)

    if change.length
      @trigger("change:#{option}") for option in change
      @trigger("change")

  # -----------------------------------

  get: (option) ->
    @options[option]

# =============================================
#
# End contents of elements/Element.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Sprite.coffee
#
# =============================================

rippl.Sprite = class Sprite extends Element
  #
  # An extra buffer canvas created to handle any filters on the image
  #
  buffer: null

  # -----------------------------------

  _useBuffer: false

  # -----------------------------------

  _animated: false

  # -----------------------------------

  _frameDuration: 0

  # -----------------------------------

  _framesModulo: 0

  # -----------------------------------

  constructor: (options, canvas) ->
    @addDefaults
      src: null
      cropX: 0
      cropY: 0

    super(options, canvas)

  # -----------------------------------

  validate: (options) ->
    super(options)
    if options.src isnt undefined
      if typeof options.src is 'string'
        options.src = asset = rippl.assets.get(options.src)
      else
        asset = options.src

      if not asset.__isLoaded
        asset.once 'loaded', =>
          @canvas.touch() if @canvas
          @calculateFrames()
          @calculateAnchor()
      else
        @calculateFrames()

  # -----------------------------------

  calculateFrames: ->
    src = @options.src
    @options.width = src._width if @options.width is 0
    @options.height = src._height if @options.height is 0
    @_framesModulo = ~~(src._width / @options.width)

  # -----------------------------------

  render: ->
    anchor = @getAnchor()

    if @_useBuffer
      @canvas.drawAsset(@buffer, -anchor.x, -anchor.y, @options.width, @options.height)
    else
      @canvas.drawAsset(@options.src, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)

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

    x += anchor.x
    y += anchor.y

    return false if x <= 0 or x > options.width
    return false if y <= 0 or y > options.height

    x = Math.round(x + options.cropX)
    y = Math.round(y + options.cropY)

    return false if options.src.getPixelAlpha(x, y) is 0

    return true

  # -----------------------------------

  addAnimation: (label, fps, frames, lastFrame) ->
    #
    # Handle fps
    #
    fps = 1 if fps <= 0

    #
    # Handle frame ranges
    #
    if typeof frames is 'number'
      lastFrame = frames if typeof lastFrame isnt 'number'
      frames = [frames..lastFrame]

    animations = @_animations or (@_animations = {})

    animations[label] =
      frames: frames
      frameDuration: 1000 / fps

    @

  # -----------------------------------

  animate: (label) ->
    label ? label = 'idle'
    animation = @_animations[label]
    return if not animation

    @_frames = animation.frames
    @_frameDuration = animation.frameDuration
    @_currentIndex = -1
    @_animationStart = Date.now()
    @_animationEnd = @_animationStart + @_frames.length * @_frameDuration
    @_animated = true

  # -----------------------------------

  progress: (frameTime) ->
    if @_animated and @_framesModulo
      return @animate() if frameTime >= @_animationEnd

      index = ~~((frameTime - @_animationStart) / @_frameDuration)
      if index isnt @_currentIndex
        @_currentIndex = index
        @setFrame(@_frames[index])

    #
    # Progress transformations *AFTER* frame has been set
    #
    super(frameTime)

  # -----------------------------------

  setFrame: (frame) ->
    @_useBuffer = false

    frameX = frame % @_framesModulo
    frameY = ~~(frame / @_framesModulo)

    @options.cropX = frameX * @options.width
    @options.cropY = frameY * @options.height
    @canvas.touch()

  # -----------------------------------

  freeze: ->
    @_animated = false

  # -----------------------------------

  createBuffer: ->
    if not @buffer
      @buffer = new Canvas
        width: @options.width
        height: @options.height
        static: true
    else
      @buffer.clear()

    @buffer.drawAsset(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
    @buffer

  # -----------------------------------

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    @createBuffer()

    @_useBuffer = true
    fn.apply(@buffer, args)
    @canvas.touch()

  # -----------------------------------

  clearFilters: ->
    return if not @buffer?
    @buffer.clear()
    @buffer.drawAsset(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  removeFilter: ->
    delete @buffer
    @buffer = null
    @_useBuffer = false
    @canvas.touch()

# =============================================
#
# End contents of elements/Sprite.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Shape.coffee
#
# =============================================

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
    super(options)
    options.color = @validateColor(options.color) if options.color isnt undefined
    options.strokeColor = @validateColor(options.strokeColor) if options.strokeColor isnt undefined
    options.shadowColor = @validateColor(options.shadowColor) if options.shadowColor isnt undefined

  # -----------------------------------

  drawPath: ->

  # -----------------------------------

  render: ->
    @canvas.setShadow(@options.shadowX, @options.shadowY, @options.shadowBlur, @options.shadowColor) if @options.shadow

    ctx = @canvas.ctx

    ctx.beginPath()

    #
    # Set line properties
    #
    ctx.lineCap = @options.lineCap
    ctx.lineJoin = @options.lineJoin

    #
    # Draw path
    #
    @drawPath()

    #
    # Erase background before drawing?
    #
    if @options.erase
      ctx.save()
      ctx.globalCompositeOperation = 'destination-out'
      ctx.globalAlpha = 1.0
      @canvas.fill('#000000')
      ctx.restore()

    #
    # Fill and stroke if applicable
    #
    @canvas.fill(@options.color) if @options.fill
    @canvas.stroke(@options.stroke, @options.strokeColor) if @options.stroke > 0

    #ctx.closePath()

# =============================================
#
# End contents of elements/Shape.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Text.coffee
#
# =============================================

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

# =============================================
#
# End contents of elements/Text.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Rectangle.coffee
#
# =============================================

rippl.Rectangle = class Rectangle extends Shape
  constructor: (options, canvas) ->
    @addDefaults
      cornerRadius: 0 # radius of rounded corners

    super(options, canvas)

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()
    ctx = @canvas.ctx

    if @options.cornerRadius is 0
      ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
    else
      x = -anchor.x
      y = -anchor.y
      w = @options.width
      h = @options.height
      r = @options.cornerRadius

      ctx.moveTo(x + w - r, y)
      ctx.quadraticCurveTo(x + w, y, x + w, y + r)
      ctx.lineTo(x + w, y + h - r)
      ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h)
      ctx.lineTo(x + r, y + h)
      ctx.quadraticCurveTo(x, y + h, x, y + h - r)
      ctx.lineTo(x, y + r)
      ctx.quadraticCurveTo(x, y, x + r, y)
      ctx.closePath()

# =============================================
#
# End contents of elements/Rectangle.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Circle.coffee
#
# =============================================

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
# =============================================
#
# End contents of elements/Circle.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/Ellipse.coffee
#
# =============================================

rippl.Ellipse = class Ellipse extends Shape
  drawPath: ->
    anchor = @getAnchor()

    ctx = @canvas.ctx
    x = -anchor.x
    y = -anchor.y
    w = @options.width
    h = @options.height

    magic = 0.551784
    ox = (w / 2) * magic  # control point offset horizontal
    oy = (h / 2) * magic  # control point offset vertical
    xe = x + w            # x-end
    ye = y + h            # y-end
    xm = x + w / 2        # x-middle
    ym = y + h / 2        # y-middle

    ctx.moveTo(x, ym)
    ctx.bezierCurveTo(x, ym - oy, xm - ox, y, xm, y)
    ctx.bezierCurveTo(xm + ox, y, xe, ym - oy, xe, ym)
    ctx.bezierCurveTo(xe, ym + oy, xm + ox, ye, xm, ye)
    ctx.bezierCurveTo(xm - ox, ye, x, ym + oy, x, ym)
    ctx.closePath()

# =============================================
#
# End contents of elements/Ellipse.coffee
#
# =============================================

# =============================================
#
# Begin contents of elements/CustomShape.coffee
#
# =============================================

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
# =============================================
#
# End contents of elements/CustomShape.coffee
#
# =============================================

# =============================================
#
# Begin contents of Canvas.coffee
#
# =============================================

rippl.Canvas = class Canvas extends ObjectAbstract
  #
  # Default options
  #
  options:
    id: null
    width: 0
    height: 0
    static: false

  # -----------------------------------

  __isAsset: true

  # -----------------------------------

  __isLoaded: true

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

    if not @options.static
      @_hoverElement = null
      @_canvas.addEventListener('touchstart', ((e) => @delegateInputEvent('touchstart', e, false, true)), true)
      @_canvas.addEventListener('touchend', ((e) => @delegateInputEvent('touchend', e, false, true)), true)
      @_canvas.addEventListener('mousedown', ((e) => @delegateInputEvent('mousedown', e)), true)
      @_canvas.addEventListener('mouseup', ((e) => @delegateInputEvent('mouseup', e)), true)
      @_canvas.addEventListener('click', ((e) => @delegateInputEvent('click', e)), true)
      @_canvas.addEventListener('mousemove', ((e) => @delegateInputEvent('mousemove', e, true)), true)
      @_canvas.onmouseleave = (e) => @handleMouseLeave()

    rippl.timer.bind(@) if not @options.static

  # -----------------------------------

  delegateInputEvent: (type, e, hover, touch) ->
    if touch
      te = e.touches[0] or e.changedTouches[0]
      x = te.pageX - @_canvas.offsetTop
      y = te.pageY - @_canvas.offsetLeft
    else
      x = e.layerX
      y = e.layerY

    e.preventDefault()

    elements = @elements
    index = elements.length

    while index--
      element = elements[index]
      if element.delegateInputEvent(type, x, y)
        if hover
          return if element is @_hoverElement

          @_hoverElement.trigger('mouseleave') if @_hoverElement isnt null
          @_hoverElement = element
          element.trigger('mouseenter')
        return

    @trigger(type)

    @handleMouseLeave() if hover

  # -----------------------------------

  handleMouseLeave: ->
    if @_hoverElement isnt null
      @_hoverElement.trigger('mouseleave')
      @_hoverElement = null

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

  add: (elements...) ->
    for element in elements
      throw "Tried to add a non-Element to Canvas" if not element.__isElement
      element.bind(@)
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

  drawRaw: (element, x, y, width, height, cropX, cropY) ->
    cropX ? cropX = 0
    cropY ? cropY = 0

    @ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height)

  # -----------------------------------

  drawAsset: (asset, x, y, width, height, cropX, cropY) ->
    return if not asset or not asset.__isAsset

    element = asset.getDocumentElement()
    return if not element

    cropX ? cropX = 0
    cropY ? cropY = 0

    @ctx.drawImage(element, cropX, cropY, width, height, x, y, width, height)

  # -----------------------------------

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    fn.apply(@, args)

  # -----------------------------------

  getPixel: (x, y) ->
    imageData = @ctx.getImageData(x, y, 1, 1)
    imageData.data

  # -----------------------------------

  getPixelAlpha: (x, y) ->
    @getPixel(x, y)[3]

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

# =============================================
#
# End contents of Canvas.coffee
#
# =============================================


define('rippl', window.rippl) if typeof define is 'function'