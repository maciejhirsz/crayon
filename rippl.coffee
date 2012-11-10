###
(c) 2012 Maciej Hirsz
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

  _validEventName: (event) ->
    return false if typeof event isnt 'string'
    return true

  # -----------------------------------

  _validCallback: (callback) ->
    return false if typeof callback isnt 'function'
    return true

  # -----------------------------------

  on: (event, callback) ->
    #
    # sets up an event handler for a specific event
    #
    return @ if not @_validEventName(event)
    return @ if not @_validCallback(callback)

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

    @

  # -----------------------------------

  off: (event, callbackToRemove) ->
    return @ if not handlers = @_eventHandlers

    if not @_validEventName(event)
      #
      # Drop all listeners
      #
      @_eventHandlers = {}

    else if not @_validCallback(callbackToRemove)
      #
      # Drop all listeners for specified event
      #
      return @ if handlers[event] is undefined

      delete handlers[event]

    else
      #
      # Drop only the specified callback from the stack
      #
      return @ if handlers[event] is undefined

      stack = []

      for callback in handlers[event]
        stack.push(callback) if callback isnt callbackToRemove

      handlers[event] = stack

  # -----------------------------------

  trigger: (event, args...) ->
    return @ if not handlers = @_eventHandlers

    #
    # triggers all listener callbacks of a given event, pass on the data from second argument
    #
    return @ if not @_validEventName(event)

    return @ if handlers[event] is undefined

    callback.apply(this, args) for callback in handlers[event]

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

rippl.Timer = class Timer extends ObjectAbstract
  #
  # Default options
  #
  options:
    fps: 60
    autoStart: true

  # -----------------------------------

  _useAnimatinFrame: false

  # -----------------------------------

  frameDuration: 0

  # -----------------------------------

  constructor: (options) ->
    @setOptions(options)

    @frameDuration = 1000 / @options.fps

    #@_useAnimatinFrame = true if window.requestAnimationFrame and @options.fps is 60

    @canvas = []

    @start() if @options.autoStart

  # -----------------------------------

  setFps: (fps) ->
    @options.fps = fps
    @frameDuration = 1000 / @options.fps

  # -----------------------------------

  bind: (canvas) ->
    @canvas.push(canvas)

  # -----------------------------------

  start: ->
    @time = Date.now()

    if @_useAnimatinFrame
      @timerid = window.requestAnimationFrame (time) => @tick(time)
    else
      @timerid = setTimeout(
        => @tickLegacy()
        @frameDuration
      )

  # -----------------------------------

  stop: ->
    if @_useAnimatinFrame
      window.cancelAnimationFrame(@timerid)
    else
      window.clearTimeout(@timerid)

  # -----------------------------------

  getSeconds: ->
    ~~(Date.now() / 1000)

  # -----------------------------------

  tick: (frameTime) ->
    frameTime = Date.now if not frameTime

    @trigger('frame', frameTime)

    canvas.render(frameTime) for canvas in @canvas

    @timerid = window.requestAnimationFrame (time) => @tick(time)

  # -----------------------------------

  tickLegacy: ->
    frameTime = Date.now()

    @time += @frameDuration
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

  rgbaPattern: new RegExp('\\s*rgba\\(\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([\.0-9]+)\s*\\)\\s*', 'i')

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
        throw "Invalid color string: "+hash

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
    @_image = new Image
    @_image.onload = =>
      @_width = @_image.naturalWidth
      @_height = @_image.naturalHeight
      @__isLoaded = true
      @trigger('loaded')
    @_image.src = url

  # -----------------------------------

  cache: (label, filter, args...) ->
    return if not @__isLoaded

    cache = @_cache or (@_cache = {})

    buffer = cache[label] = new Canvas
      width: @_width
      height: @_height

    buffer.drawSprite(@, 0, 0, @_width, @_height)

    args.unshift(filter)
    buffer.filter.apply(buffer, args)

  # -----------------------------------

  cached: (label) ->
    return @ if not @_cache
    return @_cache[label] if @_cache[label]
    return @

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

  # -----------------------------------
  #
  # Override to validate specific options, such as colors or images
  #
  validate: (options) ->

  # -----------------------------------

  validateColor: (value) ->
    value = new Color(value) if not value.__isColor
    value

  # -----------------------------------

  getAnchor: ->
    if @options.anchorInPixels
      x: @options.anchorX
      y: @options.anchorY
    else
      x: @options.anchorX * @options.width
      y: @options.anchorY * @options.height

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

  transformStop: ->
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

    if @options.snap
      x = ~~@options.x
      y = ~~@options.y
    else
      x = @options.x
      y = @options.y

    ctx.setTransform(@options.scaleX, @options.skewX, @options.skewY, @options.scaleY, x, y)
    ctx.globalAlpha = @options.alpha if @options.alpha isnt 1
    ctx.rotate(@options.rotation) if @options.rotation isnt 0
    ctx.globalCompositeOperation = @options.composition if @options.composition isnt 'source-over'

  # -----------------------------------
  #
  # Abstract method that actually draws the element on the canvas, only triggered if the element is not hidden
  #
  render: ->

  # -----------------------------------

  set: (target, value) ->
    if value isnt undefined and typeof target is 'string'
      option = target
      @validate(option: target)

      if @options[option] isnt undefined and @options[option] isnt value
        @options[option] = value
        @trigger("change:#{option}")
        @trigger("change")
        return

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
      fps: 0

    super(options, canvas)

    if @options.fps isnt 0
      @_frameDuration = 1000 / options.fps

  # -----------------------------------

  validate: (options) ->
    if typeof options.src is 'string'
      options.src = asset = rippl.assets.get(options.src)
      if not asset.__isLoaded
        asset.on 'loaded', =>
          @canvas.touch() if @canvas
          @calculateFrames()
      else
        @calculateFrames()

    if typeof options.fps is 'number'
      if options.fps is 0
        @stop()
      else
        @_frameDuration = 1000 / options.fps

  # -----------------------------------

  calculateFrames: ->
    @_framesModulo = ~~(@options.src._width / @options.width)

  # -----------------------------------

  render: ->
    anchor = @getAnchor()

    if @buffer?
      @canvas.drawSprite(@buffer, -anchor.x, -anchor.y, @options.width, @options.height)
    else
      @canvas.drawSprite(@options.src, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  addAnimation: (label, frames) ->
    animations = @_animations or (@_animations = {})
    animations[label] = frames
    @

  # -----------------------------------

  animate: (label) ->
    label ? label = 'idle'
    @_frames = @_animations[label]
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

  stop: ->
    @_animated = false

  # -----------------------------------

  createBuffer: ->
    if not @buffer
      @buffer = new Canvas
        width: @options.width
        height: @options.height
    else
      @buffer.clear()

    @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
    @buffer

  # -----------------------------------

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    @createBuffer()

    fn.apply(@buffer, args)

  # -----------------------------------

  clearFilters: ->
    return if not @buffer?
    @buffer.clear()
    @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)

  # -----------------------------------

  removeFilter: ->
    delete @buffer
    @buffer = null
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
      radius: 0 # radius of rounded corners

    super(options, canvas)

  # -----------------------------------

  drawPath: ->
    anchor = @getAnchor()
    ctx = @canvas.ctx

    if @options.radius is 0
      ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
    else
      x = -anchor.x
      y = -anchor.y
      w = @options.width
      h = @options.height
      r = @options.radius

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

    ctx = @canvas.ctx

    ctx.moveTo(@options.rootX - anchor.x, @options.rootY - anchor.y)
    for point in @points
      if point is null
        ctx.closePath()
      else
        [x, y, line] = point
        if line
          ctx.lineTo(x - anchor.x, y - anchor.y)
        else
          ctx.moveTo(x - anchor.x, y - anchor.y)

  # -----------------------------------

  lineTo: (x, y) ->
    @points.push([x, y, true])

  # -----------------------------------

  moveTo: (x, y) ->
    @points.push([x, y, false])

  # -----------------------------------

  close: ->
    @points.push(null)
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

  filter: (filter, args...) ->
    fn = rippl.filters[filter]
    return if typeof fn isnt 'function'

    fn.apply(@, args)

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


define(window.rippl) if typeof define is 'function'