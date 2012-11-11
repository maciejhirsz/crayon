
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
      @off('loaded') # loaded happens only once

    @_image.src = url

  # -----------------------------------

  cache: (label, filter, args...) ->
    return if not @__isLoaded

    cache = @_cache or (@_cache = {})

    buffer = cache[label] = new Canvas
      width: @_width
      height: @_height
      static: true

    buffer.drawAsset(@, 0, 0, @_width, @_height)

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