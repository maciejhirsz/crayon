###
(c) 2012 Maciej Hirsz
Rippl may be freely distributed under the MIT license.
###

(->
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
  
    _eventHandlers: null
  
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
      return if not @_validEventName(event)
      return if not @_validCallback(callback)
  
      #
      # Create a container for event handlers
      #
      @_eventHandlers = {} if @_eventHandlers is null
  
      #
      # create a new stack for the callbacks if not defined yet
      #
      @_eventHandlers[event] = [] if @_eventHandlers[event] is undefined
  
      #
      # push the callback onto the stack
      #
      @_eventHandlers[event].push(callback)
  
    # -----------------------------------
  
    off: (event, callbackToRemove) ->
      return if @_eventHandlers is null
  
      if not @_validEventName(event)
        #
        # Drop all listeners
        #
        @_eventHandlers = {}
  
      else if not @_validCallback(callbackToRemove)
        #
        # Drop all listeners for specified event
        #
        return if @_eventHandlers[event] is undefined
  
        delete @_eventHandlers[event]
  
      else
        #
        # Drop only the specified callback from the stack
        #
        return if @_eventHandlers[event] is undefined
  
        stack = []
  
        for callback in @_eventHandlers[event]
          stack.push(callback) if callback isnt callbackToRemove
  
        @_eventHandlers[event] = stack
  
    # -----------------------------------
  
    trigger: (event, data) ->
      return if @_eventHandlers is null
  
      #
      # triggers all listener callbacks of a given event, pass on the data from second argument
      #
      return if not @_validEventName(event)
  
      return false if @_eventHandlers[event] is undefined
  
      callback(data) for callback in @_eventHandlers[event]
  
      return true
  
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
    a: 255
  
    # -----------------------------------
  
    __isColor: true
  
    # -----------------------------------
  
    string: 'rgba(255,255,255,255)'
  
    # -----------------------------------
  
    rgbaPattern: new RegExp('\\s*rgba\\(\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\\s*\\,\\s*([0-9]{1,3})\s*\\)\\s*', 'i')
  
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
      @a = ~~a if a isnt undefined
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
  
    parseColors: (value) ->
      if typeof value is 'string' and value[0] is '#'
        return new Color(value)
  
      return value
  
    # -----------------------------------
  
    constructor: (options) ->
      @setOptions(options)
      @startTime = Date.now() + @options.delay
      @endTime = @startTime + @options.duration
  
      @
  
      @options.from[option] = @parseColors(value) for option, value of @options.from
      @options.to[option] = @parseColors(value) for option, value of @options.to
  
    # -----------------------------------
  
    isFinished: ->
      @finished
  
    # -----------------------------------
  
    getStage: (time) ->
      return 0 if time < @startTime
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
  
      options = {}
      stage = @getStage(time)
  
      from = @options.from
      to = @options.to
  
      for option of to
        options[option] = @getValue(from[option], to[option], stage)
  
      element.set(options)
  
      #
      # Finish the transformation
      #
      if time >= @endTime
        @finished = true
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
  
    constructor: (url) ->
      @_image = new Image
      @_image.onload = =>
        @__isLoaded = true
        @trigger('loaded')
      @_image.src = url
  
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
      return if typeof options.to isnt 'object'
  
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
    #
    # Used to progress current tranformation stack
    #
    progress: (frameTime) ->
      return if not @transformCount
  
      newStack = []
      for transform in @transformStack
        transform.progress(@, frameTime)
        newStack.push(transform) if not transform.isFinished()
  
      @transformStack = newStack
      @transformCount = newStack.length
  
    # -----------------------------------
    #
    # Used to set alpha, position, scale and rotation on the canvas prior to rendering.
    #
    prepare: ->
      ctx = @canvas.ctx
      ctx.setTransform(@options.scaleX, @options.skewX, @options.skewY, @options.scaleY, @options.x, @options.y)
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
  
        if @options[option] isnt undefined and @options[option] isnt value
          @options[option] = value
          @validate(@options)
  
          @trigger("change:#{option}")
          @trigger("change")
          return
  
      change = []
  
      for option, value of target
        if @options[option] isnt undefined and @options[option] isnt value
          @options[option] = value
          change.push(option)
  
      if change.length
        @validate(@options)
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
    #
    # If set to true, the sprite will perform frame animations
    #
    animated: false
  
    # -----------------------------------
  
    #
    # Internal counter for animation purposes
    #
    count: 0
  
    # -----------------------------------
  
    #
    # List of frames to play in animation
    #
    @playFrames = []
  
    # -----------------------------------
  
    #
    # Current frame the animation is on.
    #
    # IMPORTANT: This is an index of @playFrames array, NOT @frames!
    #
    currentFrame: 0
  
    # -----------------------------------
  
    constructor: (options, canvas) ->
      @addDefaults
        src: null
        cropX: 0
        cropY: 0
  
      super(options, canvas)
  
      #
      # Set of animation frames the sprite supports, can be empty
      #
      @frames = []
  
    # -----------------------------------
  
    validate: (options) ->
      throw "Sprite: src option can't be null" if options.src is null
      if typeof options.src is 'string'
        options.src = asset = rippl.assets.get(options.src)
        if not asset.__isLoaded
          asset.on('loaded', => @canvas.touch() if @canvas)
  
    # -----------------------------------
  
    setFrame: (index) ->
      #
      # Get the properties of the frame
      #
      frame = @frames[index]
  
      #
      # Change cropping properties to the given frame
      #
      @options.cropX = frame[0]
      @options.cropY = frame[1]
      @removeFilters() # this will also call @canvas.touch()
  
    # -----------------------------------
  
    render: ->
      #
      # If sprite is animated we check if current frame matches the animation interval
      #
      if @animated and @count % @animated is 0
        #
        # Switch frame
        #
        @setFrame(@playFrames[@currentFrame])
  
        #
        # Iterate to the next frame
        #
        @currentFrame += 1
        @currentFrame = 0 if @currentFrame is @playFrames.length
  
      anchor = @getAnchor()
  
      if @buffer?
        @canvas.drawSprite(@buffer, -anchor.x, -anchor.y, @options.width, @options.height)
      else
        @canvas.drawSprite(@options.src, -anchor.x, -anchor.y, @options.width, @options.height, @options.cropX, @options.cropY)
  
    # -----------------------------------
  
    createBuffer: ->
      delete @buffer
      @buffer = new Canvas
        width: @options.width
        height: @options.height
  
      @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
  
    # -----------------------------------
  
    clearFilters: ->
      return if not @buffer?
      @buffer.clear()
      @buffer.drawSprite(@options.src, 0, 0, @options.width, @options.height, @options.cropX, @options.cropY)
  
    # -----------------------------------
  
    removeFilters: ->
      delete @buffer
      @buffer = null
      @canvas.touch()
  
    # -----------------------------------
  
    invertColorsFilter: ->
      @createBuffer() if not @buffer?
      @buffer.invertColorsFilter()
  
    # -----------------------------------
  
    saturationFilter: (saturation) ->
      @createBuffer() if not @buffer?
      @buffer.saturationFilter(saturation)
  
    # -----------------------------------
  
    contrastFilter: (contrast) ->
      @createBuffer() if not @buffer?
      @buffer.contrastFilter(contrast)
  
    # -----------------------------------
  
    brightnessFilter: (brightness) ->
      @createBuffer() if not @buffer?
      @buffer.brightnessFilter(brightness)
  
    # -----------------------------------
  
    gammaFilter: (gamma) ->
      @createBuffer() if not @buffer?
      @buffer.gammaFilter(gamma)
  
    # -----------------------------------
  
    hueShiftFilter: (shift) ->
      @createBuffer() if not @buffer?
      @buffer.hueShiftFilter(shift)
  
    # -----------------------------------
  
    colorizeFilter: (hue) ->
      @createBuffer() if not @buffer?
      @buffer.colorizeFilter(hue)
  
    # -----------------------------------
  
    ghostFilter: (alpha) ->
      @createBuffer() if not @buffer?
      @buffer.ghostFilter(alpha)
  
    # -----------------------------------
  
    animate: (interval, from, to) ->
      #
      # Starts animating the sprite
      #
      #   interval - optional (default 1), number of canvas frame renders between each animation frame of the sprite
      #   from - optional (default 0), starting frame of the animation
      #   to - optional (default to last frame), ending frame of the animation
      #
  
      #
      # Handle the defaults
      #
      interval ? interval = 1
      from = 0 if from is undefined
      to = @frames.length - 1 if to is undefined
  
      #
      # Create the list of frame indexes to play
      #
      @playFrames = [from..to]
  
      #
      # Reset the currentFrame to 0
      #
      @currentFrame = 0
  
      #
      # Start animating if there actually are any frames declared!
      #
      if @playFrames.length
        @count = 0
        @animated = interval
  
    # -----------------------------------
  
    stop: ->
      #
      # Stop animation
      #
      @playFrames = []
      @animated = 0
  
    # -----------------------------------
  
    addFrame: (cropX, cropY) ->
      #
      # Create animation frame, return the amount of frames already on the sprite
      #
      @frames.push [cropX, cropY]

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
  
      if @options.radius is 0
        @canvas.ctx.rect(-anchor.x, -anchor.y, @options.width, @options.height)
      else
        @roundRect(-anchor.x, -anchor.y, @options.width, @options.height, @options.radius)
  
    # -----------------------------------
  
    roundRect: (x, y, width, height, radius) ->
      ctx = @canvas.ctx
      ctx.moveTo(x + width - radius, y)
      ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
      ctx.lineTo(x + width, y + height - radius)
      ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
      ctx.lineTo(x + radius, y + height)
      ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
      ctx.lineTo(x, y + radius)
      ctx.quadraticCurveTo(x, y, x + radius, y)
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
  
      super(options, canvas)
  
      @options.width = @options.radius * 2
      @options.height = @options.radius * 2
  
    # -----------------------------------
  
    drawPath: ->
      @canvas.ctx.arc(0, 0, @options.radius, 0, Math.PI * 2, false)
  # =============================================
  #
  # End contents of elements/Circle.coffee
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
        @options.width = Number @_canvas.width
        @options.height = Number @_canvas.height
      else
        @_canvas = document.createElement('canvas')
        @_canvas.setAttribute('width', @options.width)
        @_canvas.setAttribute('height', @options.height)
  
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
  
    toDataUrl: ->
      @_canvas.toDataURL()
  
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

  # =============================================
  #
  # End contents of Canvas.coffee
  #
  # =============================================


)(window)

define(window.rippl) if typeof define is 'function'