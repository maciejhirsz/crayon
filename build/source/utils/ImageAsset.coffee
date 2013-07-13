
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
