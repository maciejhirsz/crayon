
rippl.Sprite = class Sprite extends Element
  #
  # An extra buffer canvas created to handle any filters on the image
  #
  buffer: null

  # -----------------------------------

  constructor: (options, canvas) ->
    @addDefaults
      src: null
      cropX: 0
      cropY: 0

    super(options, canvas)

  # -----------------------------------

  validate: (options) ->
    throw "Sprite: src option can't be null" if options.src is null
    if typeof options.src is 'string'
      options.src = asset = rippl.assets.get(options.src)
      if not asset.__isLoaded
        asset.on('loaded', => @canvas.touch() if @canvas)

  # -----------------------------------

  render: ->
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
