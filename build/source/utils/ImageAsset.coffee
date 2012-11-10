
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
      @__isLoaded = true

      @_width = @_image.naturalWidth
      @_height = @_image.naturalHeight

      @trigger('loaded')
    @_image.src = url

  # -----------------------------------

  getDocumentElement: ->
    return @_image if @__isLoaded
    return null